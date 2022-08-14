defmodule Mobupay.Services.Twilio do
  @moduledoc false

  require Logger

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

    IO.inspect(payload)

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    post_request(endpoint, payload, headers, options)
  end

  def verify_msisdn(msisdn, country_code) do



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
end
