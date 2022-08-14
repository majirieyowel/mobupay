defmodule Mobupay.Account.BankAccount do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Account.User

  @derive {Jason.Encoder, only: [:ref, :name, :bank_name, :nuban, :inserted_at]}

  @required_attrs ~w{
      ref
      name
      bank_name
      nuban
      cbn_code
      currency
    }a

  schema "bank_accounts" do
    field(:ref, :string)
    field(:nuban, :string)
    field(:cbn_code, :string)
    field(:bank_name, :string)
    field(:name, :string)
    field(:currency, :string)
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(bank_account, attrs) do
    bank_account
    |> cast(attrs, @required_attrs)
    |> validate_required_fields()
    |> validate_unique_nuban(attrs)
  end

  defp validate_required_fields(changeset) do
    changeset
    |> validate_required([:nuban], message: "Account number is required")
    |> validate_required([:cbn_code], message: "Bank code is required")
    |> validate_required([:bank_name], message: "Bank name is required")
    |> validate_required([:name], message: "Account name is required")
    |> validate_required([:currency], message: "Currrency is required")
  end

  defp validate_unique_nuban(changeset, %{"nuban" => nuban, "user_id" => user_id}) do
    case Mobupay.Account.nuban_exists?(user_id, nuban) do
      true ->
        add_error(
          changeset,
          :nuban,
          "Account number already exists"
        )

      _ ->
        changeset
    end
  end
end
