defmodule MobupayWeb.TransferController do
  use MobupayWeb, :controller

  alias Mobupay.Helpers.{Response, Utility, Token, EC, CountryData}
  alias Mobupay.Transactions
  alias Mobupay.Account
  alias Mobupay.MsisdnRepos
  alias Mobupay.Services.{Twilio}
  alias MobupayWeb.ErrorHelpers

  require Logger

  # Matches request with no email address present in the payload, prompt user to add email here
  def index(
        %Plug.Conn{
          assigns: %{current_user: %Mobupay.Account.User{email: email}}
        } = conn,
        _params
      )
      when is_nil(email) do
    conn
    |> Response.error(
      400,
      "Please add your email address"
    )
  end

  # Handles default payment
  def index(
        %Plug.Conn{
          assigns: %{
            current_user: %Account.User{email: email, msisdn: from_msisdn} = user
          }
        } = conn,
        %{
          "amount" => amount,
          "to_msisdn" => to_msisdn,
          "narration" => narration,
          "ip_address" => ip_address,
          "device" => device,
          "funding_channel" => "Default"
        } = params
      ) do
    Logger.info("Received request to transfer with params #{inspect(params)}")

    with %Ecto.Changeset{valid?: true} <- Transactions.validate_transaction(params),
         amount <- Utility.remove_decimal(amount),
         ref <- Token.generate(:random),
         {:ok, _} <- ensure_no_self_funding(from_msisdn, to_msisdn),
         {:ok, _} <- ensure_same_country_code(user, to_msisdn),
         {:ok, :verified} <- lookup_msisdn(to_msisdn),
         {:ok, %Transactions.Transaction{}} <-
           Transactions.create_transaction(%{
             ref: ref,
             status: :initiated,
             from_msisdn: from_msisdn,
             to_msisdn: "wait_" <> to_msisdn,
             amount: amount,
             narration: narration,
             ip_address: ip_address,
             is_visible: false,
             device: device
           }) do
      conn
      |> Response.ok(%{
        paystack_pk: System.get_env("PAYSTACK_PUBLIC_KEY"),
        amount: amount,
        ref: ref,
        channels: ["card"],
        email: email,
        funding_channel: "Default"
      })
    else
      %Ecto.Changeset{} = changeset ->
        conn
        |> Response.error(
          422,
          "Form contains errors",
          Ecto.Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
        )

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error(
          "Transfer with bindings: #{inspect(binding())} failed with error: #{inspect(error)}"
        )

        conn
        |> Response.error(500, "An error occured while initiating transfer")
    end
  end

  # Handles existing card payment
  def index(
        %Plug.Conn{
          assigns: %{
            current_user: %Account.User{email: email, msisdn: from_msisdn} = user
          }
        } = conn,
        %{
          "amount" => amount,
          "to_msisdn" => to_msisdn,
          "narration" => narration,
          "ip_address" => ip_address,
          "device" => device,
          "card" => card_ref,
          "funding_channel" => "Existing Card"
        } = params
      ) do
    Logger.info("Received request to transfer with params #{inspect(params)}")

    with {:ok, _} <- ensure_no_self_funding(from_msisdn, to_msisdn),
         %Ecto.Changeset{valid?: true} <- Transactions.validate_transaction(params),
         {:ok, :verified} <- lookup_msisdn(to_msisdn),
         %Account.Card{authorization_code: authcode} <-
           Account.get_user_card_by_ref(user, card_ref) |> IO.inspect(),
         {:ok,
          %Transactions.Transaction{amount: transaction_amount, ref: reference} = transaction} <-
           Transactions.create_transaction(%{
             ref: Token.generate(:random),
             status: :initiated,
             from_msisdn: from_msisdn,
             to_msisdn: "wait_" <> to_msisdn,
             amount: Utility.remove_decimal(amount),
             narration: narration,
             ip_address: ip_address,
             device: device
           }),
         {:ok, %{"data" => %{"currency" => currency}}} <-
           paystack_charge_auth(%{
             email: email,
             amount: transaction_amount,
             authcode: authcode,
             reference: reference
           }),
         {:ok, %Transactions.Transaction{}} <-
           Transactions.update_transaction_status(transaction, :floating),
         {:ok, %Transactions.Transaction{to_msisdn: to_msisdn}} <-
           Transactions.normalize_to_msisdn(transaction) do
      conn
      |> Response.ok(%{
        transaction_amount: transaction_amount,
        transaction_currency: currency,
        to_msisdn: to_msisdn,
        card: %{},
        funding_channel: "Existing Card"
      })
    else
      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error(
          "Error initiating paystack transaction (old card) with payload: #{inspect(params)} and error: #{inspect(error)}"
        )

        conn
        |> Response.error(
          500,
          "E#{EC.get("unhandled_charge_authorization_error")} - Unable to process transaction at the moment, please try again later."
        )
    end
  end

  # Handles payment from balance
  # TODO: check for previous floating sent in balance too
  def index(
        %Plug.Conn{
          assigns: %{
            current_user: %Account.User{country: country, msisdn: from_msisdn} = user
          }
        } = conn,
        %{
          "amount" => amount,
          "to_msisdn" => to_msisdn,
          "narration" => narration,
          "ip_address" => ip_address,
          "device" => device,
          "funding_channel" => "Balance"
        } = params
      ) do
    Logger.info("Received request to transfer with params #{inspect(params)}")

    with %Ecto.Changeset{valid?: true} <- Transactions.validate_transaction(params),
         amount <- Utility.remove_decimal(amount),
         {:ok, _} <- ensure_no_self_funding(from_msisdn, to_msisdn),
         {:ok, _} <- Transactions.verify_sufficient_funds(user, amount, :book_balance),
         {:ok, :verified} <- lookup_msisdn(to_msisdn),
         {:ok, %Transactions.Transaction{amount: transaction_amount} = transaction} <-
           Transactions.create_transaction(%{
             ref: Token.generate(:random),
             status: :floating,
             from_msisdn: from_msisdn,
             to_msisdn: to_msisdn,
             amount: amount,
             narration: narration,
             ip_address: ip_address,
             device: device
           }),
         {:ok, %Transactions.Transaction{}} <-
           Transactions.update_transaction_status(transaction, :floating),
         #  {:ok, %Transactions.Ledger{}} <-
         #    maybe_create_account_balance_entry(transaction, :minus, :from_msisdn),
         new_balance <- Transactions.get_balance(user),
         {:ok, currency} <- CountryData.get_currency(country) do
      conn
      |> Response.ok(%{
        transaction_amount: transaction_amount,
        new_balance: new_balance,
        transaction_currency: currency,
        to_msisdn: to_msisdn,
        card: %{},
        funding_channel: "Existing Card"
      })
    else
      %Ecto.Changeset{} = changeset ->
        conn
        |> Response.error(
          422,
          "Form contains errors",
          Ecto.Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
        )

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error(
          "Error initiating paystack transaction (old card) with payload: #{inspect(params)} and error: #{inspect(error)}"
        )

        conn
        |> Response.error(
          500,
          "E#{EC.get("unhandled_charge_authorization_error")} - Unable to process transaction at the moment, please try again later."
        )
    end
  end

  def verify(
        %Plug.Conn{
          assigns: %{current_user: user}
        } = conn,
        %{"ref" => ref} = params
      ) do
    with %Transactions.Transaction{
           amount: transaction_amount
         } = transaction <-
           Transactions.get_by_ref(ref),
         {:ok, %{"currency" => currency} = paystack_data} <- verify_on_paystack(ref),
         {:ok, %Transactions.Transaction{}} <-
           Transactions.update_transaction_status(transaction, :floating),
         {:ok, %Transactions.Transaction{to_msisdn: to_msisdn} = transaction} <-
           Transactions.normalize_to_msisdn(transaction),
         {:ok, %Transactions.Transaction{}} <-
           Transactions.update_transaction_visibilty(transaction, true),
         {:ok, card} <- maybe_save_card(user, paystack_data) do
      Task.Supervisor.async_nolink(Mobupay.TaskSupervisor, fn ->
        notify_receiver(transaction, currency)
      end)

      conn
      |> Response.ok(%{
        to_msisdn: to_msisdn,
        transaction_currency: currency,
        transaction_amount: transaction_amount,
        card: card
      })
    else
      %Transactions.Transaction{} ->
        conn
        |> Response.error(
          404,
          "E#{EC.get("transaction_not_found")} - Unable to verify transaction"
        )

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error(
          "Error verifying paystack transaction with payload: #{inspect(params)} and error: #{inspect(error)}"
        )

        conn
        |> Response.error(
          500,
          "E#{EC.get("unhandled_transaction_verification_error")} - Unable to verify transaction"
        )
    end
  end

  def notify_receiver(
        %Transactions.Transaction{
          to_msisdn: to_msisdn,
          from_msisdn: from_msisdn,
          amount: amount
        },
        currency
      ) do
    formatted_amount = Number.Currency.number_to_currency(amount / 100, unit: currency)

    frontend_url = String.trim_trailing(System.get_env("MOBUPAY_FRONTEND_URL"), "/")

    message =
      case Account.msisdn_exists?(to_msisdn) do
        true ->
          "You received #{formatted_amount} from #{from_msisdn}. Login on #{frontend_url}/login to accept."

        false ->
          "You received #{formatted_amount} from #{from_msisdn}. Register on #{frontend_url} to accept."
      end

    Twilio.send(to_msisdn, message)
  end

  @doc """

  Accepts a floating payment.

  """
  def accept(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"ref" => ref} = params
      ) do
    Logger.info("Received request to accept payment with params #{inspect(params)}")

    with %Transactions.Transaction{status: :floating} = transaction <-
           get_transaction_by_reference(ref),
         {:ok, :msisdn_match} <- to_msisdn_match(user, transaction),
         {:ok, _} <- Transaction.accept_money(user, transaction) do
      conn
      |> Response.ok(%{
        transaction: transaction
      })
    else
      %Transactions.Transaction{} ->
        conn
        |> Response.error(
          400,
          "E#{EC.get("transaction_not_floating")} - Unable to accept payment"
        )

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error(
          "Error accepting payment with ref: #{inspect(ref)}, Error: #{inspect(error)}"
        )

        conn
        |> Response.error(
          500,
          "E#{EC.get("unhandled_payment_accept_error")} - Unable to accept payment"
        )
    end
  end

  def reject(
        %Plug.Conn{
          assigns: %{
            current_user: user
          }
        } = conn,
        %{"ref" => ref} = params
      ) do
    Logger.info("Received request to reject payment with params #{inspect(params)}")

    #  {:ok, %Transactions.Ledger{}} <-
    #    maybe_create_ledger_entry(transaction, :plus, :from_msisdn)
    with %Transactions.Transaction{status: :floating} = transaction <-
           Transactions.get_by_ref(ref),
         {:ok, :msisdn_match} <- to_msisdn_match(user, transaction),
         {:ok, %Transactions.Transaction{}} <-
           Transactions.update_transaction_status(transaction, :rejected) do
      conn
      |> Response.ok()
    else
      nil ->
        conn
        |> Response.error(
          404,
          "E#{EC.get("transaction_not_found")} - Unable to process payment"
        )

      %Mobupay.Transactions.Transaction{} ->
        conn
        |> Response.error(
          400,
          "E#{EC.get("transaction_not_floating")} - Unable to process payment"
        )

      {:error, :msisdn_mismatch} ->
        conn
        |> Response.error(
          400,
          "E#{EC.get("permission_denied_to_payment")} - Unable to process payment"
        )

      error ->
        Logger.error(
          "Error accepting payment with ref: #{inspect(ref)}, Error: #{inspect(error)}"
        )

        conn
        |> Response.error(
          404,
          "E#{EC.get("unhandled_payment_accept_error")} - Unable to accept payment"
        )
    end
  end

  def reclaim(
        %Plug.Conn{
          assigns: %{
            current_user: user
          }
        } = conn,
        %{"ref" => ref} = params
      ) do
    Logger.info("Received request to reclaim payment with params #{inspect(params)}")

    with %Transactions.Transaction{status: :floating} = transaction <-
           Transactions.get_by_ref(ref),
         {:ok, :msisdn_match} <- from_msisdn_match(user, transaction),
         {:ok, %Transactions.Transaction{} = transaction} <-
           Transactions.update_transaction_status(transaction, :reclaimed),
         #  {:ok, %Transactions.Ledger{}} <-
         #    maybe_create_ledger_entry(transaction, :plus, :from_msisdn),
         new_balance <- Transactions.get_balance(user) do
      conn
      |> Response.ok(%{
        new_balance: new_balance,
        transaction: transaction
      })
    else
      nil ->
        conn
        |> Response.error(
          404,
          "E#{EC.get("transaction_not_found")} - Unable to process payment"
        )

      %Mobupay.Transactions.Transaction{} ->
        conn
        |> Response.error(
          400,
          "E#{EC.get("transaction_not_floating")} - Transaction is not in a floating state and cannot be reclaimed"
        )

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error(
          "Error accepting payment with ref: #{inspect(ref)}, Error: #{inspect(error)}"
        )

        conn
        |> Response.error(
          500,
          # TODO: Add this to errors
          "E#{EC.get("unhandled_payment_reject_error")} - Unable to accept payment"
        )
    end
  end

  defp to_msisdn_match(%Account.User{msisdn: msisdn}, %Transactions.Transaction{
         to_msisdn: to_msisdn
       }) do
    cond do
      msisdn === to_msisdn ->
        {:ok, :msisdn_match}

      msisdn !== to_msisdn ->
        {:error, "E#{EC.get("permission_denied_to_payment")} - Unable to process payment"}
    end
  end

  defp from_msisdn_match(%Account.User{msisdn: msisdn}, %Transactions.Transaction{
         from_msisdn: from_msisdn
       }) do
    cond do
      msisdn === from_msisdn ->
        {:ok, :msisdn_match}

      msisdn !== from_msisdn ->
        {:error, "E#{EC.get("permission_denied_to_payment")} - Unable to process payment"}
    end
  end

  defp maybe_create_account_balance_entry(transaction, type, msisdn_field) do
    case Transactions.account_balance_entry_exists?(transaction, msisdn_field) do
      true ->
        {:ok, %Transactions.AccountBalance{}}

      false ->
        Transactions.create_ledger_entry(transaction, type, msisdn_field)
    end
  end

  defp maybe_create_book_balance_entry(transaction, type, msisdn_field) do
    case Transactions.ledger_entry_exists?(transaction, msisdn_field) do
      true ->
        {:ok, %Transactions.BookBalance{}}

      false ->
        Transactions.create_ledger_entry(transaction, type, msisdn_field)
    end
  end

  defp verify_on_paystack(ref) do
    case Application.get_env(:mobupay, :paystack_service).verify_transaction(ref) do
      {:ok, %{"status" => true, "data" => %{"status" => "success"} = data}} ->
        {:ok, data}

      _ ->
        {:error,
         "E#{EC.get("transaction_not_successful_on_paystack")} - Unable to verify transaction"}
    end
  end

  defp maybe_save_card(user, %{"channel" => "card", "authorization" => authorization}) do
    Account.create_card(user, authorization)
  end

  defp maybe_save_card(_user, _params), do: {:ok, %{}}

  defp paystack_charge_auth(params) do
    case Application.get_env(:mobupay, :paystack_service).charge_authorization(params) do
      {:ok, %{"status" => true, "data" => %{"status" => "success"}} = paystack_data} ->
        {:ok, paystack_data}

      {:ok, %{"data" => %{"gateway_response" => gateway_response}}} ->
        message =
          "E#{EC.get("unable_to_charge_authorization")} - Unable to charge card, please use another card!. Gateway Response: #{gateway_response}"

        {:error, message}
    end
  end

  defp ensure_no_self_funding(user_msisdn, to_msisdn) do
    if user_msisdn === to_msisdn do
      {:error, "E#{EC.get("transaction_to_same_msisdn")} - Cannot transfer to your phone number."}
    else
      {:ok, to_msisdn}
    end
  end

  defp ensure_same_country_code(%Account.User{country: country}, to_msisdn) do
    %{"dialing_code" => current_user_dialing_code, "name" => country_name} =
      Map.get(CountryData.get_by(:country), String.downcase(country))

    case String.starts_with?(to_msisdn, current_user_dialing_code) do
      true ->
        {:ok, current_user_dialing_code}

      false ->
        {:error,
         "You can only send money to mobile numbers in #{country_name} (+#{current_user_dialing_code})"}
    end
  end

  defp lookup_msisdn(msisdn) do
    lookup = MsisdnRepos.lookup_msisdn(msisdn)

    case lookup do
      {:ok, :verified} ->
        lookup

      _ ->
        {:error, "E#{EC.get("invalid_phone_number")} - Phone number is invalid"}
    end
  end

  defp get_transaction_by_reference(ref) do
    Transactions.get_by_ref(ref)
    |> case do
      nil ->
        "E#{EC.get("transaction_not_found")} - Unable to process payment"

      transaction ->
        transaction
    end
  end
end
