defmodule Mobupay.Transfer do
  import Ecto.Query, warn: false

  alias Mobupay.Repo
  alias Ecto.Multi
  alias Mobupay.Transactions.BookBalance
  alias Mobupay.Transactions.AccountBalance
  alias Mobupay.Account.User
  alias Mobupay.Transactions.Transaction

  # Accept from card payment
  @spec accept_money(%User{}, %Transaction{}) :: {:ok, map}
  def accept_money(
        %User{account_balance: account_balance, book_balance: book_balance, msisdn: _msisdn} =
          user,
        %Transaction{
          id: transaction_id,
          payment_channel: :card,
          to_msisdn: to_msisdn,
          from_msisdn: _from_msisdn,
          amount: amount
        } = transaction
      ) do
    new_status = %{status: :accepted}

    new_user_balance = %{
      book_balance: add(book_balance, amount),
      account_balance: add(account_balance, amount)
    }

    account_balance =
      transaction
      |> Ecto.build_assoc(:account_balance)

    book_balance =
      transaction
      |> Ecto.build_assoc(:book_balance)

    multi =
      Multi.new()
      |> Multi.update(:status, Transaction.status_changeset(transaction, new_status))
      |> Multi.update(:balance, User.update_balance_changeset(user, new_user_balance))
      |> Multi.insert(
        :account_balance,
        AccountBalance.changeset(account_balance, %{
          amount: amount,
          msisdn: to_msisdn,
          transaction_id: transaction_id
        })
      )
      |> Multi.insert(
        :book_balance,
        BookBalance.changeset(book_balance, %{
          amount: amount,
          msisdn: to_msisdn,
          transaction_id: transaction_id
        })
      )

    Repo.transaction(multi)
  end

   # Accept from balance payment
  def accept_money(_user, %Transaction{payment_channel: :balance}) do
  end

  @spec reject_money(%User{}, %Transaction{}) :: {:ok, map}
  def reject_money(
        %User{account_balance: account_balance, book_balance: book_balance, msisdn: _msisdn} =
          user,
        %Transaction{
          id: transaction_id,
          payment_channel: :card,
          to_msisdn: to_msisdn,
          from_msisdn: _from_msisdn,
          amount: amount
        } = transaction
      ) do
    new_status = %{status: :accepted}

    new_user_balance = %{
      book_balance: add(book_balance, amount),
      account_balance: add(account_balance, amount)
    }

    account_balance =
      transaction
      |> Ecto.build_assoc(:account_balance)

    book_balance =
      transaction
      |> Ecto.build_assoc(:book_balance)

    multi =
      Multi.new()
      |> Multi.update(:status, Transaction.status_changeset(transaction, new_status))
      |> Multi.update(:balance, User.update_balance_changeset(user, new_user_balance))
      |> Multi.insert(
        :account_balance,
        AccountBalance.changeset(account_balance, %{
          amount: amount,
          msisdn: to_msisdn,
          transaction_id: transaction_id
        })
      )
      |> Multi.insert(
        :book_balance,
        BookBalance.changeset(book_balance, %{
          amount: amount,
          msisdn: to_msisdn,
          transaction_id: transaction_id
        })
      )

    Repo.transaction(multi)
  end

  def reject_money(_user, %Transaction{payment_channel: :balance}) do
  end

  defp add(value1, value2) when is_integer(value1) and is_integer(value2) do
    value1 + value2
  end
end
