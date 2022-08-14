defmodule MobupayWeb.BankAccountController do
  use MobupayWeb, :controller

  alias Mobupay.Account
  alias Mobupay.Helpers.Response
  require Logger

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    Logger.info("Received request to create bank account with details #{inspect(params)}")

    with {:ok, %Mobupay.Account.BankAccount{} = bank_account} <-
           Account.create_bank_account(user, params) do
      conn
      |> Response.ok(%{
        bank_account: bank_account
      })
    else
      {:error, %Ecto.Changeset{valid?: false} = changeset} ->
        conn
        |> Response.ecto_changeset_error(changeset)

      error ->
        Logger.error(
          "Adding bank account failed for user: #{inspect(user.id)} with response #{inspect(error)}"
        )

        conn
        |> Response.error(:bad_request)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => bank_account_ref}) do
    Logger.info("Received request to delete bank account with ref #{inspect(bank_account_ref)}")

    case Account.list_bank_account_by_ref(bank_account_ref) do
      %Account.BankAccount{user_id: user_id} = bank_account ->
        # TODO: Save event
        if user_id === user.id, do: Account.delete_bank_account(bank_account)

        conn
        |> Response.ok(%{}, :ok, "Bank account deleted successfully")

      nil ->
        conn
        |> Response.error(404, "Bank account not found")
    end

    # Account.list_bank_account_by_ref

    # Account.delete_bank_account()
  end
end
