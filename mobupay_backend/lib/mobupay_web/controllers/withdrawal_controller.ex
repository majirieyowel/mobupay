defmodule MobupayWeb.WithdrawalController do
  use MobupayWeb, :controller

  alias Mobupay.Helpers.{Response, Token, ErrorCode, Utility, Pagination}
  alias Mobupay.Services.{Redis, Paystack}
  alias Mobupay.Account
  alias Mobupay.Transactions

  require Logger

  def index(
        %Plug.Conn{
          assigns: %{current_user: %Mobupay.Account.User{} = user}
        } = conn,
        params
      ) do
    withdrawals = Account.list_user_withdrawals(user, params)

    conn
    |> Response.ok(Pagination.format("withdrawals", withdrawals))
  end

  def initiate(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{
          "amount" => amount,
          "bank_account_ref" => bank_account_ref,
          "ip_address" => ip_address,
          "device" => device
        } = params
      ) do
    Logger.info("Received request to withdraw funds with params #{inspect(params)}")

    with reference <- Token.generate(:random),
         amount <- Utility.remove_decimal(amount),
         otp <- Token.generate(:otp),
         %Account.BankAccount{
           nuban: nuban,
           bank_name: bank_name,
           cbn_code: cbn_code,
           name: bank_account_name
         } <-
           Account.list_user_bank_account_by_ref(user, bank_account_ref),
         {:ok, _} <- Transactions.verify_sufficient_funds(user, amount),
         {:ok, %Account.Withdrawal{}} <-
           Account.create_withdrawal(user, %{
             ref: reference,
             customer_ref: Token.generate(10),
             bank_account_number: nuban,
             bank_name: bank_name,
             status: :initiated,
             amount: amount,
             ip_address: ip_address,
             device: device
           }),
         {:ok, _key} <-
           Redis.set_with_expiration(
             otp <> "_" <> reference,
             %{
               "otp" => otp,
               "ip" => ip_address,
               "cbn_code" => cbn_code,
               "bank_account_name" => bank_account_name
             },
             600
           ) do
      IO.inspect("OTP: #{otp}")

      conn
      |> Response.ok(%{
        "reference" => reference
      })
    else
      nil ->
        conn
        |> Response.error(
          400,
          "E#{ErrorCode.get("bank_account_not_found")} - An Error occured while withdrawing funds"
        )

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error("Withdrawal initiation request failed with error #{inspect(error)}")

        conn
        |> Response.error(
          500,
          "E#{ErrorCode.get("unhandled_withdrawal_initiation_error")} - An Error occured while withdrawing funds"
        )
    end
  end

  def complete(
        %Plug.Conn{assigns: %{current_user: _user}} = conn,
        %{
          "ref" => ref,
          "otp" => otp,
          "ip_address" => completion_ip
        } = params
      ) do
    Logger.info("Received request to verify funds transfer with params #{inspect(params)}")

    with {:ok,
          %{
            "ip" => initiation_ip,
            "cbn_code" => bank_code,
            "bank_account_name" => bank_account_name
          }} <-
           Redis.get_map(otp <> "_" <> ref),
         {:ok, _ip} <- validate_same_ip(initiation_ip, completion_ip),
         %Account.Withdrawal{bank_account_number: bank_account_number, amount: amount, ref: ref} <-
           Account.get_withdrawal_by_ref(ref),
         {:ok, recipient_code} <-
           create_recipient(%{
             bank_code: bank_code,
             name: bank_account_name,
             account_number: bank_account_number
           }),
         {:ok, _trs} <-
           transfer(%{amount: amount, reference: ref, recipient_code: recipient_code}) do
      conn
      |> Response.ok()
    else
      {:ok, nil} ->
        conn
        |> Response.error(
          400,
          "E#{ErrorCode.get("invalid_withdrawal_otp")} - Invalid/Exipred OTP"
        )

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error("Withdrawal complete request failed with error #{inspect(error)}")

        conn
        |> Response.error(
          500,
          "E#{ErrorCode.get("unhandled_withdrawal_completion_error")} - An error occured while completing withdrawal"
        )
    end
  end

  defp create_recipient(attrs) do
    case Paystack.create_transfer_recipient(attrs) do
      {:ok, %{"status" => true, "data" => %{"recipient_code" => recipient_code}}} ->
        {:ok, recipient_code}

      _ ->
        {:error,
         "E#{ErrorCode.get("error_creating_transfer_recipient")} - An error occured while completing withdrawal"}
    end
  end

  defp transfer(attrs) do
    case Paystack.transfer(attrs) do
      {:ok, %{"status" => true}} ->
        {:ok, "ok"}

      response ->
        Logger.error("Completing withdrawal failed with error: #{inspect(response)}")

        {:error,
         "E#{ErrorCode.get("error_transfering_funds")} - An error occured while completing withdrawal"}
    end
  end

  defp validate_same_ip(initiation_ip, completion_ip) do
    cond do
      initiation_ip === completion_ip ->
        {:ok, completion_ip}

      initiation_ip !== completion_ip ->
        {:error,
         "E#{ErrorCode.get("ip_address_mismatch")} - An error occured while completing withdrawal"}
    end
  end
end
