defmodule MobupayWeb.SessionController do
  use MobupayWeb, :controller

  use Timex

  alias Mobupay.{Account, Guardian}
  alias Mobupay.Helpers.Response

  require Logger

  def login(conn, %{"msisdn" => msisdn, "password" => password})
      when is_bitstring(msisdn) and is_bitstring(password) do
    with %Account.User{} = user <- Account.get_by_msisdn(msisdn),
         true <-
           Bcrypt.verify_pass(password, user.hashed_password),
         {:ok, access_token, refresh_token, _access_token_claims} <- Guardian.generate_token(user) do
      conn
      |> Response.ok(%{
        access_token: access_token,
        refresh_token: refresh_token
      })
    else
      _ ->
        conn
        |> Response.error(401, "Authentication failed!")
    end
  end

  def login(conn, _), do: Response.error(conn, 401, "Authentication failed!")

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Guardian.exchange(refresh_token, "refresh", "access") do
      {:ok, _, {new_token, new_claims}} ->
        conn
        |> Response.ok(%{access_token: new_token, claims: new_claims})

      _error ->
        conn
        |> Response.error(401, "Invalid/Missing input")
    end
  end

  def logout(conn, _params) do
    # conn = Guardian.Plug.sign_out(conn)

    # {:ok, claims} = Guardian.revoke(token)
    # IO.inspect(claims)
    conn
    |> Response.ok()
  end
end
