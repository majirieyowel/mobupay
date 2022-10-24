defmodule Mobupay.AccountManager do
  alias Ecto.Multi

  def accept_money(user, transaction) do
    Multi.new()
  end

  #  {:ok, %Transactions.Transaction{} = transaction} <-
  #        Transactions.update_transaction_status(transaction, :accepted)

  # credit all
  # > user balance
  # > account entry
  # > book entry

  # minus all
  # > user balance
  # > account entry
  # > book entry

  # minus account
  # > user balance
  # > account entry
  # > book entry

  # minus book
  # > user balance
  # > account entry
  # > book entry

  # def reset(account, params) do
  #   Multi.new()
  #   |> Multi.update(:account, Account.password_reset_changeset(account, params))
  #   |> Multi.insert(:log, Log.password_reset_changeset(account, params))
  #   |> Multi.delete_all(:sessions, Ecto.assoc(account, :sessions))
  # end
end
