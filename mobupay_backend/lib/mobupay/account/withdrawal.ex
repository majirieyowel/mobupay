defmodule Mobupay.Account.Withdrawal do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.WithdrawalStatusEnum
  alias Mobupay.Account

  @cast_attrs ~w{
      ref
      customer_ref
      amount
      status
      bank_account_number
      bank_name
      ip_address
      device
    }a

  @derive {Jason.Encoder,
           only: [
             :ref,
             :amount,
             :customer_ref,
             :status,
             :bank_account_number,
             :bank_name,
             :inserted_at
           ]}

  schema "withdrawals" do
    field :ref, :string
    field :customer_ref, :string
    field :amount, :integer
    field :status, WithdrawalStatusEnum
    field :bank_account_number, :string
    field :bank_name, :string
    field :ip_address, :string
    field :device, :string

    belongs_to(:user, Account.User)

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @cast_attrs)
    |> validate_amount(attrs)
  end

  def validate_amount(changeset, %{amount: amount}) do
    validate_amount(changeset, %{"amount" => amount})
  end

  def validate_amount(changeset, %{"amount" => amount}) do
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
