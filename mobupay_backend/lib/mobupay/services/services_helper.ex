defmodule Mobupay.Services.ServicesHelper do
  require Logger

  @doc "Make a post request using HTTPoison client"
  @spec post_request(String.t(), String.t(), map(), list(), list()) ::
          {:ok, map()} | {:error, any}
  def post_request(module, endpoint, payload, headers, options) do
    with {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} <-
           HTTPoison.post(endpoint, payload, headers, options),
         {:ok, json} <- Jason.decode(body) do
      Logger.info("#{module} response: #{inspect(json)}")

      {:ok, json}
    else
      error ->
        Logger.error("#{module} post error response: {inspect(error)}")
        {:error, error}
    end
  end

  @doc "Make a post request using HTTPoison client"
  @spec get_request(String.t(), String.t(), list(), list()) :: {:ok, map()} | {:error, any}
  def get_request(module, endpoint, headers, options) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(endpoint, headers, options),
         {:ok, json} <- Jason.decode(body) do
      Logger.info("#{module} GET response: #{inspect(body)} ")
      {:ok, json}
    else
      error ->
        Logger.error("#{module} get error response: #{inspect(error)}")
        {:error, error}
    end
  end
end
