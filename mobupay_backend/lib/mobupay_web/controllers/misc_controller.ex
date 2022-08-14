defmodule MobupayWeb.MiscController do
  use MobupayWeb, :controller

  alias Mobupay.Services.Paystack
  alias Mobupay.Helpers.{Response}

  require Logger

  def resolve_account_number(
        conn,
        %{"bank_code" => bank_code, "account_number" => account_number}
      ) do
    case Paystack.resolve_account_number(%{
           bank_code: bank_code,
           account_number: account_number
         }) do
      {:ok, %{"data" => %{"account_name" => account_name, "account_number" => account_number}}} ->
        conn
        |> Response.ok(%{
          "account_number" => account_number,
          "account_name" => account_name
        })

      _ ->
        conn
        |> Response.error(400, "Unable to verify account number, review and try again")
    end
  end

  def validate_international_msisdn(conn, %{"msisdn" => msisdn}) do
    conn
    |> Response.ok()
  end

  def validate_international_msisdn(conn, _) do
    conn
    |> Response.error(400, "Missing/Invalid phone number")
  end
end
