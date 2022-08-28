defmodule Mobupay.CountryData do
  require Logger

  @countries_info_file_path "lib/mobupay/data/countries_data.txt"

  def get_currency(country) do
    parsed =
      parse_data()
      |> Stream.map(&parse_to_maps(&1))
      |> Stream.filter(fn item -> item["name"] == country end)
      |> Enum.into([])

    case parsed do
      [%{"currency" => currency}] ->
        {:ok, currency}

      _ ->
        {:error, "Currency for #{country} was not found"}
    end
  end

  def get_by(:country_code) do
    parse_data()
    |> Stream.map(&parse_by_country_code(&1))
    |> Enum.into(%{})
  end

  def get_by(:country) do
    parse_data()
    |> Stream.map(&parse_by_country(&1))
    |> Enum.into(%{})
  end

  defp parse_data do
    [_header | data_rows] = File.read!(@countries_info_file_path) |> String.split("\n")

    data_rows
    |> Stream.map(&String.split(&1, "\t"))
    |> Stream.map(&remove_spaces(&1))
  end

  defp remove_spaces([row]) do
    String.replace(row, ~r/\s+/, " ")
    |> String.split(" ")
  end

  defp parse_by_country_code([
         country,
         country_code,
         dialing_code,
         msisdn_length,
         currency,
         currency_unit
       ]) do
    {String.downcase(country_code),
     %{
       "name" => country,
       "country_code" => country_code,
       "dialing_code" => dialing_code,
       "msisdn_length" => String.to_integer(msisdn_length),
       "currency" => currency,
       "currency_unit" => currency_unit
     }}
  end

  defp parse_by_country([
         country,
         country_code,
         dialing_code,
         msisdn_length,
         currency,
         currency_unit
       ]) do
    {String.downcase(country),
     %{
       "name" => country,
       "country_code" => country_code,
       "dialing_code" => dialing_code,
       "msisdn_length" => String.to_integer(msisdn_length),
       "currency" => currency,
       "currency_unit" => currency_unit
     }}
  end

  defp parse_to_maps([
         country,
         country_code,
         dialing_code,
         msisdn_length,
         currency,
         currency_unit
       ]) do
    %{
      "name" => country,
      "country_code" => country_code,
      "dialing_code" => dialing_code,
      "msisdn_length" => String.to_integer(msisdn_length),
      "currency" => currency,
      "currency_unit" => currency_unit
    }
  end

  def get_country_info(country) do
    Map.get(parse_data(), country)
    |> case do
      nil ->
        {:error, "Mobupay service is not available in country code #{country}"}

      {_code, _msisdn_length, _currency} = country_info ->
        {:ok, country_info}
    end
  end
end
