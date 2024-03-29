defmodule Mobupay.Transactions do
  @moduledoc """
  The Transaction context.
  """
  import Ecto.Query, warn: false
  alias Mobupay.Repo
  alias Mobupay.Helpers.{Token, EC}
  alias Mobupay.Transactions.{Transaction, AccountBalance, BookBalance}
  alias Mobupay.Account

  def validate_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
  end

  # TODO: Investigate this function properly
  def list_user_transactions(%Account.User{msisdn: msisdn}, params \\ %{}) do
    Transaction
    |> where([t], t.from_msisdn == ^msisdn)
    |> or_where([t], t.to_msisdn == ^msisdn)
    |> where([t], t.is_visible == true)
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

  def update_transaction(transaction, attrs) do
    transaction
    |> Transaction.update_transaction_changeset(attrs)
    |> Repo.update()
  end

  def get_by_ref(ref) do
    Transaction
    |> where([t], t.ref == ^ref)
    |> Repo.one()
  end

  # TODO: Obsolete as we use changeset now
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

  # TODO obsolete
  def update_transaction_visibilty(transaction, visibility) do
    Repo.update(Ecto.Changeset.change(transaction, is_visible: visibility))
  end

  # Balance

  @doc """
  Checks if an account balance entry exists
  """
  @spec account_balance_entry_exists?(%Transaction{}, atom()) :: boolean()
  def account_balance_entry_exists?(
        %Transaction{id: transaction_id, to_msisdn: msisdn},
        :to_msisdn
      ),
      do: do_account_balance_entry_exists?(transaction_id, msisdn)

  def account_balance_entry_exists?(
        %Transaction{id: transaction_id, from_msisdn: msisdn},
        :from_msisdn
      ),
      do: do_account_balance_entry_exists?(transaction_id, msisdn)

  @doc """
  Checks if a book balance entry exists
  """
  def book_balance_entry_exists?(%Transaction{id: transaction_id, to_msisdn: msisdn}, :to_msisdn),
    do: do_book_balance_entry_exists?(transaction_id, msisdn)

  def book_balance_entry_exists?(
        %Transaction{id: transaction_id, from_msisdn: msisdn},
        :from_msisdn
      ),
      do: do_book_balance_entry_exists?(transaction_id, msisdn)

  @doc """
    Verifies if a user has sufficient funds
  """
  @spec verify_sufficient_funds(%Account.User{}, integer(), atom()) ::
          {:ok, balance :: integer()} | {:error, String.t()}
  def verify_sufficient_funds(user, amount, :book_balance) do
    balance = get_book_balance(user)

    if balance > amount do
      {:ok, balance}
    else
      {:error, "Insufficient Balance"}
    end
  end

  def verify_sufficient_funds(user, amount, :account_balance) do
    balance = get_account_balance(user)

    if balance > amount do
      {:ok, balance}
    else
      {:error, "Insufficient Balance"}
    end
  end

  # TODO obsolete as balances are obtained from user column
  def get_balance(%Account.User{msisdn: msisdn}) do
    amount =
      Ledger
      |> where([l], l.msisdn == ^msisdn)
      |> Repo.aggregate(:sum, :amount)

    amount
  end

  @doc """
    Fetches a users account balance
  """
  @spec get_account_balance(%Account.User{}) :: integer()
  def get_account_balance(%Account.User{msisdn: msisdn}) do
    amount =
      AccountBalance
      |> where([l], l.msisdn == ^msisdn)
      |> Repo.aggregate(:sum, :amount)

    case amount do
      nil ->
        0

      _ ->
        amount
    end
  end

  @doc """
    Fetches a users book balance
  """
  @spec get_book_balance(%Account.User{}) :: integer()
  def get_book_balance(%Account.User{msisdn: msisdn}) do
    amount =
      BookBalance
      |> where([l], l.msisdn == ^msisdn)
      |> Repo.aggregate(:sum, :amount)

    case amount do
      nil ->
        0

      _ ->
        amount
    end
  end

  @doc """
    Creates a ledger entry for account balance
  """
  @spec create_account_balance_entry(%Transaction{}, atom(), :to_msisdn) ::
          {:ok, %AccountBalance{}}
  def(
    create_account_balance_entry(
      %Transaction{to_msisdn: to_msisdn, amount: amount} = transaction,
      type,
      :to_msisdn
    )
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

  @spec create_book_balance_entry(%Transaction{}, atom(), :to_msisdn) :: {:ok}
  def create_book_balance_entry(
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

  def get_transaction_ledger(transaction_id) do
    Ledger
    |> where([l], l.transaction_id == ^transaction_id)
    |> Repo.one()
  end

  defp get_ledger_amount(type, amount) do
    case type do
      :plus ->
        amount

      :minus ->
        -amount
    end
  end

  # defp do_ledger_entry_exists?(transaction_id, msisdn) do
  #   Ledger
  #   |> where([l], l.transaction_id == ^transaction_id)
  #   |> where([l], l.msisdn == ^msisdn)
  #   |> Repo.exists?()
  # end

  defp do_account_balance_entry_exists?(transaction_id, msisdn) do
    AccountBalance
    |> where([l], l.transaction_id == ^transaction_id)
    |> where([l], l.msisdn == ^msisdn)
    |> Repo.exists?()
  end

  defp do_book_balance_entry_exists?(transaction_id, msisdn) do
    BookBalance
    |> where([l], l.transaction_id == ^transaction_id)
    |> where([l], l.msisdn == ^msisdn)
    |> Repo.exists?()
  end
end
