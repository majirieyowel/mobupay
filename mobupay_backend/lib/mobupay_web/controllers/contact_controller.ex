defmodule MobupayWeb.ContactController do
  use MobupayWeb, :controller

  alias Mobupay.Account
  alias Mobupay.Helpers.{Response, Token}
  alias Mobupay.Helpers.Msisdn
  require Logger

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, _params) do
    conn
    |> Response.ok(Account.list_contacts(user_id))
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

  def import(%Plug.Conn{assigns: %{current_user: %{country: country}}} = conn, %{
        "contact" => %Plug.Upload{content_type: "text/csv", path: temp_path, filename: filename}
      }) do
    {:ok, %File.Stat{size: size}} = File.stat(temp_path)

    cond do
      size <= 100_000 ->
        temp_path
        |> Path.expand(__DIR__)
        |> File.stream!()
        |> CSV.decode!()
        |> Enum.into([], &parse_contact/1)
        |> cleanup_contacts_list
        |> Enum.map(fn %{msisdn: msisdn} = item ->
          {:ok, updated_msisdn} = Msisdn.format(country, msisdn)
          %{item | msisdn: updated_msisdn}
        end)
        |> IO.inspect()

      size > 100_00 ->
        # background process
        extension = Path.extname(filename)
        destination = "priv/static/csv/#{UUID.uuid1()}#{extension}"
        File.cp(temp_path, destination) |> IO.inspect()
    end

    conn
  end

  def cleanup_contacts_list(list) do
    list
    |> Enum.filter(fn %{name: name, msisdn: msisdn} ->
      String.length(name) > 2 && String.length(msisdn) > 10
    end)
  end

  def parse_contact(item) do
    filtered =
      item
      |> Enum.filter(fn x -> x !== "" end)

    %{
      name: extract_name(filtered),
      msisdn: extract_msisdn(filtered)
    }
  end

  def extract_name(list) do
    list
    |> Enum.filter(fn x ->
      x
      |> String.replace(~r/\s+/, "")
      |> Integer.parse()
      |> case do
        {_number, _other} ->
          false

        :error ->
          true
      end
    end)
    |> filter_name_head
  end

  def extract_msisdn(list) do
    list
    |> Enum.filter(fn x ->
      x
      |> String.replace(~r/\s+/, "")
      |> Integer.parse()
      |> case do
        {_number, _other} ->
          true

        :error ->
          false
      end
    end)
    |> filter_msisdn_head
  end

  def filter_name_head([]), do: ""

  def filter_name_head(list) do
    [head | _tail] = list

    head
  end

  def filter_msisdn_head([]), do: ""

  def filter_msisdn_head([head | _tail]), do: String.replace(head, ~r/\s+/, "")
end
