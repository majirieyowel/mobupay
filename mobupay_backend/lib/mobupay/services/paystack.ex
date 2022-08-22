defmodule Mobupay.Services.Paystack do
  @moduledoc false

  alias Mobupay.Helpers.Token

  require Logger

  @spec transfer(map()) :: {:ok, map()} | {:error, any()}
  def transfer(%{
        amount: amount,
        recipient_code: recipient_code,
        reference: reference
      }) do
    base_url = System.get_env("PAYSTACK_BASE_URL")
    endpoint = "#{base_url}transfer"
    secret_key = System.get_env("PAYSTACK_SECRET_KEY")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{secret_key}"}
    ]

    payload =
      %{
        source: "balance",
        amount: amount,
        recipient_code: recipient_code,
        reference: reference
      }
      |> Jason.encode!()

    Logger.info(
      "paystack::requesting transfer Endpoint: #{endpoint} with payload: #{inspect(payload)}"
    )

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    post_request(endpoint, payload, headers, options)
  end

  @spec create_transfer_recipient(map()) :: {:ok, map()} | {:error, any()}
  def create_transfer_recipient(%{
        bank_code: bank_code,
        name: bank_account_name,
        account_number: bank_account_number
      }) do
    base_url = System.get_env("PAYSTACK_BASE_URL")
    endpoint = "#{base_url}transferrecipient"
    secret_key = System.get_env("PAYSTACK_SECRET_KEY")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{secret_key}"}
    ]

    payload =
      %{
        type: "nuban",
        name: bank_account_name,
        account_number: bank_account_number,
        bank_code: bank_code
      }
      |> Jason.encode!()

    Logger.info(
      "paystack::requesting create_transfer_recipient Endpoint: #{endpoint} with payload: #{inspect(payload)}"
    )

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    post_request(endpoint, payload, headers, options)
  end

  @spec initialize_transaction(map()) :: {:ok, map()} | {:error, any()}
  def initialize_transaction(%{amount: amount, email: email, callback: callback}) do
    base_url = System.get_env("PAYSTACK_BASE_URL")
    endpoint = "#{base_url}transaction/initialize"
    secret_key = System.get_env("PAYSTACK_SECRET_KEY")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{secret_key}"}
    ]

    reference = Token.generate(:random)

    payload =
      %{
        email: email,
        amount: amount,
        callback_url: callback,
        reference: reference,
        currency: "NGN",
        # ["card", "bank", "ussd", "qr", "mobile_money", "bank_transfer", "eft"]
        channels: ["card"]
      }
      |> Jason.encode!()

    Logger.info(
      "paystack::requesting initialize Endpoint: #{endpoint} with payload: #{inspect(payload)}"
    )

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    post_request(endpoint, payload, headers, options)
  end

  @spec verify_transaction(String.t()) :: {:ok, map()} | {:error, any()}
  def verify_transaction(ref) do
    base_url = System.get_env("PAYSTACK_BASE_URL")
    endpoint = "#{base_url}transaction/verify/#{ref}"
    secret_key = System.get_env("PAYSTACK_SECRET_KEY")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{secret_key}"}
    ]

    Logger.info("paystack::requesting verify Endpoint: #{endpoint}")

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    get_request(endpoint, headers, options)
  end

  @spec charge_authorization(map()) :: {:ok, map()} | {:error, any()}
  def charge_authorization(%{
        email: email,
        amount: amount,
        authcode: authcode,
        reference: reference
      }) do
    base_url = System.get_env("PAYSTACK_BASE_URL")
    endpoint = "#{base_url}transaction/charge_authorization"
    secret_key = System.get_env("PAYSTACK_SECRET_KEY")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{secret_key}"}
    ]

    payload =
      %{
        email: email,
        amount: amount,
        authorization_code: authcode,
        reference: reference
      }
      |> Jason.encode!()

    Logger.info("paystack::requesting charge_authorization Endpoint: #{endpoint}")

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    post_request(endpoint, payload, headers, options)
  end

  @spec resolve_account_number(map()) :: {:ok, map()} | {:error, any()}
  def resolve_account_number(%{account_number: _account_number, bank_code: _bank_code}) do
    # base_url = System.get_env("PAYSTACK_BASE_URL")
    # endpoint = "#{base_url}bank/resolve?account_number=#{account_number}&bank_code=#{bank_code}"

    # headers = [
    #   {"Content-Type", "application/json"},
    #   {"Authorization", "Bearer #{System.get_env("PAYSTACK_SECRET_KEY")}"}
    # ]

    # Logger.info("paystack::requesting resolve account number Endpoint: #{endpoint}")

    # options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    # get_request(endpoint, headers, options)

    {:ok,
     %{
       "data" => %{
         "account_name" => "EYOWEL MAJIRI EMMANUEL",
         "account_number" => "0237389191",
         "bank_id" => 9
       },
       "message" => "Account number resolved",
       "status" => true
     }}
  end

  defp get_request(endpoint, headers, options) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(endpoint, headers, options),
         {:ok, json} <- Jason.decode(body) do
      Logger.info("Paystack api response: #{inspect(body)} ")

      {:ok, json}
    end
  end

  defp post_request(endpoint, payload, headers, options) do
    with {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} <-
           HTTPoison.post(endpoint, payload, headers, options),
         json <- Jason.decode!(body) do
      Logger.info("Paystack api response: #{inspect(body)} ")

      {:ok, json}
    else
      error ->
        Logger.error("Paystack api error response: #{inspect(error)} ")
        {:error, :failed}
    end
  end
end
