defmodule Mobupay.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Transactions.Ledger

  alias Mobupay.TransactionStatusEnum
  alias Mobupay.TransactionTypeEnum

  @derive {Jason.Encoder,
           only: [:ref, :amount, :type, :status, :msisdn, :narration, :inserted_at]}

  schema "transactions" do
    field :ref, :string
    field :callback_hash, :string
    field :amount, :integer
    field :type, TransactionTypeEnum
    field :status, TransactionStatusEnum
    field :msisdn, :string
    field :narration, :string
    field :ip_address, :string
    field :device, :string

    has_one(:ledgers, Ledger)

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :ref,
      :callback_hash,
      :amount,
      :type,
      :status,
      :msisdn,
      :narration,
      :ip_address,
      :device
    ])
    |> validate_required([:amount], message: "Amount is required!")
  end
end
