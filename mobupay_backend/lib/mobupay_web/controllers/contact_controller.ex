defmodule MobupayWeb.ContactController do
  use MobupayWeb, :controller

  alias Mobupay.Account
  alias Mobupay.Helpers.{Response, Token, Pagination}
  require Logger

  # TODO: create contacts schema, create and delete functions, persist onboading hash to local storage

  def index(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, params) do
    case Account.list_contacts(user_id, params) do
      %Scrivener.Page{} = data ->
        conn
        |> Response.ok(Pagination.format(:contacts, data))

      _ ->
        conn
        |> Response.error(500, "Currently unable to fetch your contacts")
    end
  end

  def search(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, %{"query" => query}) do
    conn
    |> Response.ok(%{
      contacts: Account.search_contacts(query, user_id)
    })
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    Logger.info("Received request to create contact with details #{inspect(params)}")

    updated_params =
      Map.put(params, "ref", Token.generate(:random))
      |> Map.put("user_id", user.id)

    with {:ok, %Mobupay.Account.Contact{} = contact} <-
           user |> Account.create_contact(updated_params) do
      conn
      |> Response.ok(%{
        contact: contact
      })
    else
      {:error, %Ecto.Changeset{valid?: false} = changeset} ->
        conn
        |> Response.ecto_changeset_error(changeset)

      error ->
        Logger.error(
          "Adding contact failed for user: #{inspect(user.id)} with response #{inspect(error)}"
        )

        conn
        |> Response.error(:bad_request)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{"id" => bank_account_ref}) do
    Logger.info("Received request to delete bank account with ref #{inspect(bank_account_ref)}")

    case Account.list_bank_account_by_ref(bank_account_ref) do
      %Account.BankAccount{} = bank_account ->
        # TODO: Save event
        Account.delete_bank_account(bank_account)

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
