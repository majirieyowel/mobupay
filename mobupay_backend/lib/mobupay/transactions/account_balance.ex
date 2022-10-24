defmodule Mobupay.Transactions.AccountBalance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Transactions.Transaction

  @derive {Jason.Encoder, only: [:amount, :msisdn]}

  schema "account_balance" do
    field :amount, :integer
    field :msisdn, :string
    belongs_to(:transaction, Transaction)

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :amount,
      :msisdn
    ])
  end
end
