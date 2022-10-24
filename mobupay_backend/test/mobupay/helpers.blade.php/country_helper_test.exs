defmodule Mobupay.Helpers.CountryDataTest do
  use MobupayWeb.ConnCase

  alias Mobupay.Helpers.CountryData

  test "get_currency/1 works as expected" do
    assert {:ok, "NGN"} = CountryData.get_currency("Nigeria")
    assert {:error, "Currency for Nigeriaa was not found"} = CountryData.get_currency("Nigeriaa")
  end

  test "get_by/1 works as expected" do
    [head | _tail] = CountryData.get_by(:country_code)

    assert %{
             "ng" => %{
               "name" => "Nigeria",
               "country_code" => "NG",
               "dialing_code" => "234",
               "currency" => "NGN"
             }
           } = head

    [head | _tail] = CountryData.get_by(:country)

    assert %{
             "nigeria" => %{
               "name" => "Nigeria",
               "country_code" => "NG",
               "dialing_code" => "234",
               "currency" => "NGN"
             }
           } = head
  end
end
