defmodule Mobupay.MsisdnRepos do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Mobupay.Repo

  alias Mobupay.MsisdnRepos.Msisdn
  alias Mobupay.Helpers.Msisdn, as: MsisdnHelper
  alias Mobupay.Services.Twilio

  def save_msisdn(country_code, msisdn) do
    %Msisdn{}
    |> Msisdn.changeset(%{
      "country_code" => country_code,
      "msisdn" => MsisdnHelper.remove_plus(msisdn)
    })
    |> Repo.insert()
  end

  def lookup_msisdn(msisdn) do
    case exists_in_database?(msisdn) do
      true ->
        format_response()

      false ->
        Twilio.lookup(msisdn)
        |> format_response()
    end
  end

  defp format_response() do
    {:ok, :verified}
  end

  defp format_response({:ok, %{"country_code" => country_code, "phone_number" => msisdn}}) do
    case save_msisdn(country_code, msisdn) do
      {:ok, _success} ->
        {:ok, :verified}

      _ ->
        {:error, :invalid}
    end
  end

  defp format_response(_params) do
    {:error, :invalid}
  end

  defp exists_in_database?(msisdn) do
    Msisdn
    |> where([m], m.msisdn == ^MsisdnHelper.remove_plus(msisdn))
    |> Repo.exists?()
  end
end
