defmodule Mobupay.Helpers.Msisdn do
  @moduledoc false

  require Logger

  @doc """
  Validates input msisdn with country

  ## Examples

      iex> validate_msisdn("08108125270", "NG")
      {:ok, "08108125270"}

      iex> validate_msisdn("081081252709", "NG")
      {:error, "Invalid phone number"}

  """
  # @spec validate_msisdn(String.t(), String.t()) :: {:ok, any} | {:error, any}
  # def validate_msisdn(_msisdn, country) do
  #   with {:ok, {_code, _msisdn_length, _currency}} <- get_country_info(country) do
  #     {:ok, "country_info"}
  #   else
  #     {:error, reason} ->
  #       Logger.error("validate_msisdn/2 failed with reason #{reason}")
  #       {:error, reason}
  #   end
  # end
end
