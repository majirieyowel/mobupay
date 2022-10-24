defmodule MobupayWeb.UserController do
  use MobupayWeb, :controller

  alias Mobupay.Helpers.Response
  alias Mobupay.Transactions
  alias Mobupay.Account
  alias Mobupay.CountryData

  alias Mobupay.Repo

  require Logger

  def user(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        _params
      ) do
    user =
      user
      |> Repo.preload([:bank_accounts])
      |> Repo.preload([:cards])

    conn
    |> Response.ok(%{
      user: user
    })
  end

  def add_email(%Plug.Conn{assigns: %{current_user: user}} = conn, param) do
    Logger.info("Received request to update email with #{inspect(param)}")

    case Account.save_email(user, param) do
      {:ok, %Account.User{} = _updated_user} ->
        conn
        |> Response.ok()

      {:error, %Ecto.Changeset{valid?: false} = changeset} ->
        conn
        |> Response.ecto_changeset_error(changeset)

      _ ->
        conn
        |> Response.error(500, "Unable to save email at this time.")
    end
  end

  def verify_password(
        %Plug.Conn{assigns: %{current_user: %{hashed_password: hashed_password}}} = conn,
        %{"password" => password}
      ) do
    conn
    |> Response.ok(%{
      "allow" => Bcrypt.verify_pass(password, hashed_password)
    })
  end
end
