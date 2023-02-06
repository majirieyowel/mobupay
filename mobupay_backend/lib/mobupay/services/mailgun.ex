defmodule Mobupay.Services.Mailgun do
  require Logger

  @doc """
    Email sender
  """
  @from "Mobupay no-reply@mobupay.com"

  @doc """
    Mailgun sender domain
  """
  @mailgun_domain "mg.roundup.ng"

  @doc """
    Sends an email using mailgun templates
  """
  @spec send(String.t(), String.t(), String.t(), map) :: {:ok, map} | {:error, String.t()}
  def send(recipient, subject, template_id, template_params) do
    mailgun_endpoint =
      "https://api:#{System.get_env("MAILGUN_API_KEY")}@api.mailgun.net/v3/#{@mailgun_domain}/messages"

    headers = [
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    payload = generate_payload(recipient, subject, template_id, template_params)

    Logger.info("Sending email with payload: #{inspect(payload)}")

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(mailgun_endpoint, payload, headers, options),
         {:ok, json_body} <- Jason.decode(body) do
      Logger.info("Mailgun server response: #{inspect(json_body)}")
      {:ok, json_body}
    else
      error ->
        Logger.error("Error: Mailgun server failed with response: #{inspect(error)}")
        {:error, :failed}
    end
  end

  defp generate_payload(recipient, subject, template_id, template_params),
    do:
      "from=#{@from}&to=#{recipient}&subject=#{subject}&template=#{template_id}&h:X-Mailgun-Variables=#{template_params |> Jason.encode!()}"
end
