defmodule Mobupay.Transfer do
  import Ecto.Query, warn: false

  alias Mobupay.Repo
  alias Ecto.Multi
  alias Mobupay.Transactions.{BookBalance, AccountBalance, Transaction}
  alias Mobupay.Account
  alias Mobupay.Helpers.Token

  # save new transaction
  # log to account balance logs
  # update user account balance
  def from_balance(%Account.User{account_balance: account_balance} = user, %{
        "from_msisdn" => from_msisdn,
        "to_msisdn" => to_msisdn,
        "amount" => amount,
        "narration" => narration,
        "ip_address" => ip_address,
        "device" => device
      }) do
    transaction = %Transaction{
      ref: Token.generate(:random),
      from_ref: Token.generate(10),
      to_ref: Token.generate(10),
      status: :floating,
      from_msisdn: from_msisdn,
      to_msisdn: to_msisdn,
      amount: amount,
      narration: narration,
      ip_address: ip_address,
      device: device,
      payment_channel: "balance"
    }

    Repo.transaction(fn ->
      transaction = Repo.insert!(transaction)

      # Subtract from sender journal
      AccountBalance.changeset(
        transaction
        |> Ecto.build_assoc(:account_balance),
        %{
          amount: -amount,
          msisdn: from_msisdn
        }
      )
      |> Repo.insert!()

      # Add to receiver journal
      AccountBalance.changeset(
        transaction
        |> Ecto.build_assoc(:account_balance),
        %{
          amount: amount,
          msisdn: to_msisdn
        }
      )
      |> Repo.insert!()

      sender =
        Account.User.update_balance_changeset(user, %{
          account_balance: subtract(account_balance, amount)
        })
        |> Repo.update!()

      # if receiver is registered sync balance
      case Account.get_by_msisdn(to_msisdn) do
        %Account.User{account_balance: receiver_account_balance} = receiver ->
          Account.User.update_balance_changeset(receiver, %{
            account_balance: add(receiver_account_balance, amount)
          })
          |> Repo.update!()

        nil ->
          nil
      end

      %{transaction: transaction, user: sender}
    end)
  end

  @doc """
  Transfers from card payment
  """
  @spec from_card(%Transaction{}) :: {:ok, map}
  def from_card(
        %Transaction{
          to_msisdn: to_msisdn,
          amount: amount
        } = transaction
      ) do
    multi =
      Multi.new()
      |> Multi.update(
        :transaction,
        Transaction.update_transaction_changeset(transaction, %{
          status: :floating,
          is_visible: true,
          to_msisdn: to_msisdn,
          payment_channel: :card
        })
      )
      |> Multi.run(:maybe_update_receiver, fn _repo, _ ->
        with %Account.User{account_balance: receiver_account_balance} = receiver <-
               Account.get_by_msisdn(to_msisdn),
             {:ok, _updated_receiver} <-
               Account.User.update_balance_changeset(receiver, %{
                 account_balance: add(receiver_account_balance, amount)
               })
               |> Repo.update()
               |> IO.inspect(label: "Add previous balance update") do
          {:ok, nil}
        else
          nil ->
            {:ok, nil}

          _ ->
            {:error, "Unable to update receiver"}
        end
      end)
      |> Multi.insert(
        :account_balance,
        AccountBalance.changeset(
          transaction
          |> Ecto.build_assoc(:account_balance),
          %{
            amount: amount,
            msisdn: to_msisdn
          }
        )
      )

    Repo.transaction(multi)

    # TODO start here
  end

  # Accept from card payment
  @spec accept_money(%Account.User{}, %Transaction{}) :: {:ok, map}
  def accept_money(
        %Account.User{
          book_balance: book_balance,
          msisdn: _msisdn
        } = user,
        %Transaction{
          payment_channel: :card,
          to_msisdn: to_msisdn,
          from_msisdn: _from_msisdn,
          amount: amount
        } = transaction
      ) do
    new_status = %{status: :accepted}

    new_user_balance = %{
      book_balance: add(book_balance, amount)
    }

    multi =
      Multi.new()
      |> Multi.update(:status, Transaction.status_changeset(transaction, new_status))
      |> Multi.update(:balance, Account.User.update_balance_changeset(user, new_user_balance))
      |> Multi.insert(
        :book_balance,
        BookBalance.changeset(transaction |> Ecto.build_assoc(:book_balance), %{
          amount: amount,
          msisdn: to_msisdn
        })
      )

    Repo.transaction(multi)
  end

  # Accept from balance payment
  def accept_money(
        %Account.User{
          book_balance: book_balance
        } = user,
        %Transaction{
          payment_channel: :balance,
          to_msisdn: to_msisdn,
          from_msisdn: from_msisdn,
          amount: amount
        } = transaction
      ) do
    new_status = %{status: :accepted}

    %Account.User{book_balance: sender_book_balance} = sender = Account.get_by_msisdn(from_msisdn)

    multi =
      Multi.new()
      |> Multi.update(:status, Transaction.status_changeset(transaction, new_status))
      |> Multi.update(
        :balance,
        Account.User.update_balance_changeset(user, %{
          book_balance: add(book_balance, amount)
        })
      )
      |> Multi.insert(
        :book_balance,
        BookBalance.changeset(
          transaction
          |> Ecto.build_assoc(:book_balance),
          %{
            amount: amount,
            msisdn: to_msisdn
          }
        )
      )
      |> Multi.update(
        :sender_balance,
        Account.User.update_balance_changeset(sender, %{
          book_balance: subtract(sender_book_balance, amount)
        })
      )
      |> Multi.insert(
        :sender_book_balance,
        BookBalance.changeset(
          transaction
          |> Ecto.build_assoc(:book_balance),
          %{
            amount: sender_book_balance,
            msisdn: from_msisdn
          }
        )
      )

    Repo.transaction(multi)
  end

  @doc """
  Reject money
  """
  # from card payment
  @spec reject_money(%Account.User{}, %Transaction{}) :: {:ok, map}
  def reject_money(
        %Account.User{
          account_balance: rejecter_balance
        } = rejecter,
        %Transaction{
          payment_channel: :card,
          to_msisdn: to_msisdn,
          from_msisdn: from_msisdn,
          amount: amount
        } = transaction
      ) do
    %Account.User{
      book_balance: sender_book_balance,
      account_balance: sender_account_balance
    } = sender = Account.get_by_msisdn(from_msisdn)

    multi =
      Multi.new()
      |> Multi.update(:status, Transaction.status_changeset(transaction, %{status: :rejected}))
      |> Multi.update(
        :balance,
        Account.User.update_balance_changeset(rejecter, %{
          account_balance: subtract(rejecter_balance, amount)
        })
      )
      |> Multi.insert(
        :rejecter_account_balance_log,
        AccountBalance.changeset(
          transaction
          |> Ecto.build_assoc(:account_balance),
          %{
            amount: -amount,
            msisdn: to_msisdn
          }
        )
      )
      |> Multi.update(
        :sender_balance,
        Account.User.update_balance_changeset(sender, %{
          account_balance: add(sender_account_balance, amount),
          book_balance: add(sender_book_balance, amount)
        })
      )
      |> Multi.insert(
        :sender_account_balance_log,
        AccountBalance.changeset(
          transaction
          |> Ecto.build_assoc(:account_balance),
          %{
            amount: amount,
            msisdn: from_msisdn
          }
        )
      )
      |> Multi.insert(
        :sender_book_balance_log,
        BookBalance.changeset(
          transaction
          |> Ecto.build_assoc(:book_balance),
          %{
            amount: amount,
            msisdn: from_msisdn
          }
        )
      )

    Repo.transaction(multi)
  end

  # from balance payment
  def reject_money(
        %Account.User{
          account_balance: rejecter_balance
        } = rejecter,
        %Transaction{
          payment_channel: :balance,
          from_msisdn: from_msisdn,
          to_msisdn: to_msisdn,
          amount: amount
        } = transaction
      ) do
    %Account.User{account_balance: sender_account_balance} =
      sender = Account.get_by_msisdn(from_msisdn)

    multi =
      Multi.new()
      |> Multi.update(:status, Transaction.status_changeset(transaction, %{status: :rejected}))
      |> Multi.update(
        :sender_balance,
        Account.User.update_balance_changeset(sender, %{
          account_balance: add(sender_account_balance, amount)
        })
      )
      |> Multi.insert(
        :sender_account_balance_log,
        AccountBalance.changeset(
          transaction
          |> Ecto.build_assoc(:account_balance),
          %{
            amount: amount,
            msisdn: from_msisdn
          }
        )
      )
      |> Multi.update(
        :balance,
        Account.User.update_balance_changeset(rejecter, %{
          account_balance: subtract(rejecter_balance, amount)
        })
      )
      |> Multi.insert(
        :rejecter_account_balance_log,
        AccountBalance.changeset(
          transaction
          |> Ecto.build_assoc(:account_balance),
          %{
            amount: -amount,
            msisdn: to_msisdn
          }
        )
      )

    Repo.transaction(multi)
  end

  defp add(value1, value2) when is_integer(value1) and is_integer(value2) do
    value1 + value2
  end

  defp subtract(value1, value2) when is_integer(value1) and is_integer(value2) do
    value1 - value2
  end
end
