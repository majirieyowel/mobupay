defmodule Mobupay.Helpers.CountryData do
  @moduledoc """
  This module contains helper functions to read the currently supported countries data structure
  """
  require Logger

  @file_path File.read!("lib/mobupay/data/countries.json")
             |> Jason.decode!()

  @doc """
  Fetches the currency symbol for a country
  """
  @spec get_currency(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def get_currency(input_country) do
    @file_path
    |> Enum.filter(fn %{"country" => country} -> country == input_country end)
    |> case do
      [%{"currency" => currency}] ->
        {:ok, currency}

      _ ->
        {:error, "Currency for #{input_country} was not found"}
    end
  end

  @doc """
  Gets countries list
  """
  @spec get_list() :: [...]
  def get_list() do
    @file_path
  end

  @doc """
  Sets the param to be the key in the list
  """
  @spec get_by(atom()) :: [...]
  def get_by(:country_code) do
    @file_path
    |> Enum.map(fn %{
                     "country" => country,
                     "country_code" => country_code,
                     "dialing_code" => dialing_code,
                     "currency" => currency
                   } ->
      %{
        String.downcase(country_code) => %{
          "name" => country,
          "country_code" => country_code,
          "dialing_code" => dialing_code,
          "currency" => currency
        }
      }
    end)
  end

  def get_by(:country) do
    @file_path
    |> Enum.map(fn %{
                     "country" => country,
                     "country_code" => country_code,
                     "dialing_code" => dialing_code,
                     "currency" => currency
                   } ->
      %{
        String.downcase(country) => %{
          "name" => country,
          "country_code" => country_code,
          "dialing_code" => dialing_code,
          "currency" => currency
        }
      }
    end)
  end
end
