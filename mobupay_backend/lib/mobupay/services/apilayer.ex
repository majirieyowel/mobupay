defmodule Mobupay.Services.Apilayer do
  @moduledoc false

  require Logger

  @score_limit 0.5

  @doc """
  Verify user email using APILAYER API
  """
  @spec verify_email(String.t()) :: {:ok, atom()} | {:error, String.t()}
  def verify_email(email) do
    request_options = [{:timeout, 32_000}, {:recv_timeout, 20_000}]

    response = HTTPoison.get(attach_email_to_url(email), headers(), request_options)

    handle_verification(response)
  end

  defp handle_verification({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    %{"score" => score} = Jason.decode!(body) |> IO.inspect()

    cond do
      score >= @score_limit ->
        {:ok, :valid}

      score < @score_limit ->
        {:error, "Email is not allowed or does not exist!"}
    end
  end

  defp handle_verification({:ok, %HTTPoison.Response{status_code: 429}}) do
    # TODO: check if below certain level and notify once
    # Notify the admin somehow
    {:error, :valid}
  end

  defp handle_verification(error) do
    Logger.error("Error verifying user email: #{inspect(error)}")
    {:error, "Unable to verify email at this time"}
  end

  defp headers(header_list \\ []) do
    [apikey: System.get_env("APILAYER_API_KEY")] ++
      header_list
  end

  def attach_email_to_url(email),
    do: String.replace(System.get_env("APILAYER_VERIFICATION_URL"), ~r/{email}/, email)
end
