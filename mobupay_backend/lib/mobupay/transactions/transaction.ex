defmodule Mobupay.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.TransactionStatusEnum
  alias Mobupay.TransactionPaymentChannelEnum

  alias Mobupay.Transactions.AccountBalance
  alias Mobupay.Transactions.BookBalance

  @cast_attrs ~w{
      ref
      to_ref
      from_ref
      amount
      status
      payment_channel
      from_msisdn
      to_msisdn
      narration
      ip_address
      is_visible
      device
    }a

  @derive {Jason.Encoder,
           only: [
             :ref,
             :to_ref,
             :from_ref,
             :amount,
             :status,
             :payment_channel,
             :from_msisdn,
             :to_msisdn,
             :narration,
             :ip_address,
             :device,
             :inserted_at
           ]}

  schema "transactions" do
    field :ref, :string
    field :to_ref, :string
    field :from_ref, :string
    field :amount, :integer
    field :status, TransactionStatusEnum
    field :payment_channel, TransactionPaymentChannelEnum
    field :from_msisdn, :string
    field :to_msisdn, :string
    field :narration, :string
    field :ip_address, :string
    field :device, :string
    field :is_visible, :boolean, default: true

    has_one(:account_balance, AccountBalance)
    has_one(:book_balance, BookBalance)

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @cast_attrs)
    |> validate_msisdn(attrs)
    |> validate_amount(attrs)
  end

  def update_transaction_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @cast_attrs)
  end

  def status_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:status])
    |> validate_required(:status)
  end

  defp validate_msisdn(changeset, _attrs) do
    changeset
    |> validate_required(:to_msisdn, message: "Phone number is required!")
  end

  defp validate_amount(changeset, %{amount: amount}) do
    validate_amount(changeset, %{"amount" => amount})
  end

  defp validate_amount(changeset, %{"amount" => amount}) do
    changeset =
      changeset
      |> validate_required(:amount, message: "Amount field is required")
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
