defmodule Mobupay.Helpers.Msisdn do
  @moduledoc false

  alias Mobupay.Helpers.CountryData

  require Logger

  def remove_plus(msisdn) do
    case String.starts_with?(msisdn, "+") do
      true ->
        {_, valid_msisdn} = String.split_at(msisdn, 1)
        valid_msisdn

      false ->
        msisdn
    end
  end

  @spec format(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def format(country, msisdn) do
    with msisdn <- String.trim(msisdn),
         %{"dialing_code" => dialing_code} <-
           Map.get(CountryData.get_by(:country), String.downcase(country)) do
      cond do
        String.starts_with?(msisdn, dialing_code) ->
          {:ok, msisdn}

        true ->
          {:ok, String.replace_prefix(msisdn, "0", dialing_code)}
      end
    else
      _error ->
        {:error, "Unable to resolve country #{country}"}
    end
  end
end
