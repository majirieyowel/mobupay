defmodule Mobupay.Services.Twilio do
  @moduledoc false

  require Logger

  @doc """
  Lookup an MSISDN on Twilio

  """
  @spec lookup(String.t()) :: {:ok, any()} | {:error, any()}
  def lookup(msisdn) do
    twilio_lookup_url = System.get_env("TWILIO_LOOKUP_URL")
    twilio_sid = System.get_env("TWILIO_SID")
    twilio_auth_token = System.get_env("TWILIO_AUTH_TOKEN")

    authorization_token = "#{twilio_sid}:#{twilio_auth_token}" |> :base64.encode()

    endpoint = "#{twilio_lookup_url}v1/PhoneNumbers/#{msisdn}"

    headers = [
      Authorization: "Basic #{authorization_token}",
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    get_request(endpoint, headers, options)
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
    twilio_base_url = System.get_env("TWILIO_BASE_URL")
    twilio_number = System.get_env("TWILIO_PHONE_NUMBER")
    twilio_sid = System.get_env("TWILIO_SID")
    twilio_auth_token = System.get_env("TWILIO_AUTH_TOKEN")

    authorization_token = "#{twilio_sid}:#{twilio_auth_token}" |> :base64.encode()

    endpoint = "#{twilio_base_url}2010-04-01/Accounts/#{twilio_sid}/Messages.json"

    headers = [
      Authorization: "Basic #{authorization_token}",
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    payload =
      %{
        Body: message,
        From: twilio_number,
        To: msisdn
      }
      |> Jason.encode!()

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    post_request(endpoint, payload, headers, options)
  end

  defp post_request(endpoint, payload, headers, options) do
    with {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} <-
           HTTPoison.post(endpoint, payload, headers, options),
         {:ok, json} <- Jason.decode(body) do
      Logger.info("#{inspect(__MODULE__)} response: #{inspect(body)} ")

      {:ok, json}
    else
      error ->
        Logger.error("#{inspect(error)}")
        {:error, error}
    end
  end

  defp get_request(endpoint, headers, options) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(endpoint, headers, options),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end
end
