defmodule Mobupay.Transactions do
  @moduledoc """
  The Account context.
  """
  import Ecto.Query, warn: false
  alias Mobupay.Repo
  alias Mobupay.Transactions.{Transaction, Ledger}
  alias Mobupay.Account
  alias Mobupay.CountryData

  def list_user_transactions(%Account.User{msisdn: msisdn}, params \\ %{}) do
    Transaction
    |> where([t], t.msisdn == ^msisdn)
    |> order_by([t], desc: t.id)
    |> Repo.paginate(params)
  end

  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def get_by_ref(ref) do
    Transaction
    |> where([t], t.ref == ^ref)
    |> Repo.one()
  end

  def update_transaction_status(transaction, status) do
    Repo.update(Ecto.Changeset.change(transaction, status: status))
  end

  # TODO: obsolete
  def get_formatted_amount(amount, country) do
    compute_amount(amount, country)
  end

  # ledger

  def ledger_entry_exists?(%Transaction{id: transaction_id}) do
    Ledger
    |> where([l], l.transaction_id == ^transaction_id)
    |> Repo.exists?()
  end

  def get_balance(%Account.User{msisdn: msisdn}) do
    amount =
      Ledger
      |> where([l], l.msisdn == ^msisdn)
      |> Repo.aggregate(:sum, :amount)

    amount
  end

  # TODO: obsolete
  def get_formatted_balance(%Account.User{msisdn: msisdn, country: country}) do
    amount =
      Ledger
      |> where([l], l.msisdn == ^msisdn)
      |> Repo.aggregate(:sum, :amount)

    compute_amount(amount, country)
  end

  # TODO: obsolete
  defp compute_amount(nil, _country), do: 0

  defp compute_amount(0, _country), do: 0

  defp compute_amount(amount, country), do: amount / CountryData.get_currency_unit(country)

  def create_ledger_entry(%Transaction{msisdn: msisdn, type: type, amount: amount} = transaction) do
    changeset =
      transaction
      |> Ecto.build_assoc(:ledgers)
      |> Ledger.changeset(%{
        msisdn: msisdn,
        amount: get_ledger_amount(type, amount)
      })

    Repo.insert(changeset)
  end

  defp get_ledger_amount(type, amount) do
    case type do
      :credit ->
        amount

      :debit ->
        -amount

      :self_fund ->
        amount
    end
  end
end
