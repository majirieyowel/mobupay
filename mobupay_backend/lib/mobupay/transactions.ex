defmodule Mobupay.Transactions do
  @moduledoc """
  The Transaction context.
  """
  import Ecto.Query, warn: false
  alias Mobupay.Repo
  alias Mobupay.Helpers.Token
  alias Mobupay.Transactions.{Transaction, Ledger}
  alias Mobupay.Account

  def validate_transaction(attrs) do
    Transaction.changeset(%Transaction{}, attrs)
  end

  def list_user_transactions(%Account.User{msisdn: msisdn}, params \\ %{}) do
    Transaction
    |> where([t], t.from_msisdn == ^msisdn)
    |> or_where([t], t.to_msisdn == ^msisdn)
    |> order_by([t], desc: t.id)
    |> Repo.paginate(params)
  end

  def create_transaction(attrs \\ %{}) do
    %Transaction{
      from_ref: Token.generate(10),
      to_ref: Token.generate(10)
    }
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def get_by_ref(ref) do
    Transaction
    |> where([t], t.ref == ^ref)
    |> Repo.one()
  end

  @spec update_transaction_status(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => any, optional(any) => any},
              optional(atom) => any
            },
          any
        ) :: any
  def update_transaction_status(transaction, status) do
    Repo.update(Ecto.Changeset.change(transaction, status: status))
  end

  def normalize_to_msisdn(%Transaction{to_msisdn: msisdn} = transaction) do
    case String.starts_with?(msisdn, "wait_") do
      true ->
        [_, msisdn] = String.split(msisdn, "_")

        Repo.update(Ecto.Changeset.change(transaction, to_msisdn: msisdn))

      false ->
        {:ok, transaction}
    end
  end

  # ledger

  @doc """
  Checks of a ledger entry exists using msisdn and transaction_id columns
  """
  def ledger_entry_exists?(%Transaction{id: transaction_id, to_msisdn: msisdn}, :to_msisdn) do
    do_ledger_entry_exists?(transaction_id, msisdn)
  end

  def ledger_entry_exists?(%Transaction{id: transaction_id, from_msisdn: msisdn}, :from_msisdn) do
    do_ledger_entry_exists?(transaction_id, msisdn)
  end

  def get_balance(%Account.User{msisdn: msisdn}) do
    amount =
      Ledger
      |> where([l], l.msisdn == ^msisdn)
      |> Repo.aggregate(:sum, :amount)

    amount
  end

  def create_ledger_entry(
        %Transaction{to_msisdn: to_msisdn, amount: amount} = transaction,
        type,
        :to_msisdn
      ) do
    changeset =
      transaction
      |> Ecto.build_assoc(:ledgers)
      |> Ledger.changeset(%{
        msisdn: to_msisdn,
        amount: get_ledger_amount(type, amount)
      })

    Repo.insert(changeset)
  end

  def create_ledger_entry(
        %Transaction{from_msisdn: from_msisdn, amount: amount} = transaction,
        type,
        :from_msisdn
      ) do
    changeset =
      transaction
      |> Ecto.build_assoc(:ledgers)
      |> Ledger.changeset(%{
        msisdn: from_msisdn,
        amount: get_ledger_amount(type, amount)
      })

    Repo.insert(changeset)
  end

  defp get_ledger_amount(type, amount) do
    case type do
      :plus ->
        amount

      :minus ->
        -amount
    end
  end

  defp do_ledger_entry_exists?(transaction_id, msisdn) do
    Ledger
    |> where([l], l.transaction_id == ^transaction_id)
    |> where([l], l.msisdn == ^msisdn)
    |> Repo.exists?()
  end
end
