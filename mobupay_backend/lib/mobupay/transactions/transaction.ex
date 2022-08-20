defmodule Mobupay.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Transactions.Ledger

  alias Mobupay.TransactionStatusEnum

  @cast_attrs ~w{
      ref
      to_ref
      from_ref
      callback_hash
      amount
      status
      from_msisdn
      to_msisdn
      narration
      ip_address
      device
    }a

  @derive {Jason.Encoder,
           only: [
             :ref,
             :to_ref,
             :from_ref,
             :amount,
             :status,
             :from_msisdn,
             :to_msisdn,
             :narration,
             :inserted_at
           ]}

  schema "transactions" do
    field :ref, :string
    field :to_ref, :string
    field :from_ref, :string
    field :callback_hash, :string
    field :amount, :integer
    field :status, TransactionStatusEnum
    field :from_msisdn, :string
    field :to_msisdn, :string
    field :narration, :string
    field :ip_address, :string
    field :device, :string

    has_one(:ledgers, Ledger)

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @cast_attrs)
    |> validate_msisdn(attrs)
    |> validate_amount(attrs)
  end

  def validate_msisdn(changeset, _attrs) do
    changeset
    |> validate_required(:to_msisdn, message: "Phone number is required!")
  end

  def validate_amount(changeset, %{amount: amount}) do
    validate_amount(changeset, %{"amount" => amount})
  end

  def validate_amount(changeset, %{"amount" => amount}) do
    changeset =
      changeset
      |> validate_required(:amount, message: "Amount fleid is required")
      |> validate_number(:amount,
        greater_than_or_equal_to: 50,
        message: "Amount must be greater than 50"
      )

    if !amount_regex?(amount) do
      add_error(
        changeset,
        :amount,
        "Amount is invalid"
      )
    else
      changeset
    end
  end

  defp amount_regex?(amount) when is_integer(amount) do
    amount_regex?(Integer.to_string(amount))
  end

  defp amount_regex?(amount) when is_bitstring(amount) do
    Regex.match?(~r/^\d{1,13}(\.\d{1,4})?$/, amount)
  end
end
