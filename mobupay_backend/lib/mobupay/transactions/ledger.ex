defmodule Mobupay.Transactions.Ledger do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Transactions.Transaction

  @derive {Jason.Encoder, only: [:amount, :msisdn]}

  schema "ledgers" do
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
