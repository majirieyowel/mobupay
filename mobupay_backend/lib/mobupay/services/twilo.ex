defmodule Mobupay.Services.Twilio do
  @moduledoc false

  import Mobupay.Services.ServicesHelper, only: [post_request: 5, get_request: 4]

  require Logger

  @request_options [{:timeout, 32_000}, {:recv_timeout, 20_000}]

  @doc """
  Lookup an MSISDN on Twilio

  """
  @spec lookup(String.t()) :: {:ok, any()} | {:error, any()}
  def lookup(msisdn) do
    endpoint = "#{System.get_env("TWILIO_LOOKUP_URL")}v1/PhoneNumbers/#{msisdn}"

    case get_request(__MODULE__, endpoint, headers(), request_options()) do
      {:ok, %{"phone_number" => _msisdn}} = resp ->
        resp

      _ ->
        {:error, "Mobile number '#{msisdn}' is invalid"}
    end
  end

  @doc """
  Send a message to a phone number

    ## Examples

      iex> send("238108125270", "89812 is your OTP")
      {:ok, "08108125270"}

      iex> send("238108125270", "89812 is your OTP")
      {:error, "Invalid phone number"}

  """
  @spec send(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  def send(msisdn, message) do
    endpoint =
      "#{System.get_env("TWILIO_BASE_URL")}2010-04-01/Accounts/#{System.get_env("TWILIO_SID")}/Messages.json"

    # payload =
    #   ~s{Body=#{message}&From=#{twilio_number}&To=#{msisdn}&StatusCallback=https://webhook.site/19151fc9-fd8f-4907-a4db-df81c42729f1}

    payload =
      ~s{Body=#{message}&From=#{System.get_env("TWILIO_PHONE_NUMBER")}&To=#{msisdn}&StatusCallback=#{System.get_env("TWILIO_WEBHOOK_URL")}}

    Logger.info("Twilio: Sending message with payload: #{payload}")

    case post_request(__MODULE__, endpoint, payload, headers(), request_options()) do
      %{"status" => "queued"} ->
        {:ok, :sent}

      _ ->
        {:error, "Unable to send SMS at this time"}
    end
  end

  @spec send_whatsapp(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  def send_whatsapp(msisdn, message) do
    endpoint =
      "#{System.get_env("TWILIO_BASE_URL")}2010-04-01/Accounts/#{System.get_env("TWILIO_SID")}/Messages.json"

    payload =
      ~s{Body=#{message}&From=whatsapp:#{System.get_env("TWILIO_WHATSAPP_NUMBER")}&To=whatsapp:#{msisdn}&StatusCallback=#{System.get_env("TWILIO_WEBHOOK_URL")}}

    Logger.info("Twilio: Sending message with payload: #{payload}")

    case post_request(__MODULE__, endpoint, payload, headers(), request_options()) do
      {:ok, %{"status" => "queued"}} ->
        {:ok, :sent}

      error ->
        Logger.error("Error sending whatsapp message. Error: #{inspect(error)}")
        {:error, "Unable to send whatsapp message at this time"}
    end
  end

  defp request_options(), do: @request_options

  # -----  Enable these when you have a custom header ----

  # defp request_options(options_list) when is_list(options_list), do: options_list
  # defp request_options(_), do: @request_options

  defp headers(header_list \\ []) do
    [Authorization: "Basic #{auth_token()}", "Content-Type": "application/x-www-form-urlencoded"] ++
      header_list
  end

  defp auth_token(),
    do:
      "#{System.get_env("TWILIO_SID")}:#{System.get_env("TWILIO_AUTH_TOKEN")}" |> :base64.encode()
end
