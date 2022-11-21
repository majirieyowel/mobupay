defmodule Mobupay.Businesses.Business do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Account

  @derive {Jason.Encoder, only: [:ref, :name, :email, :logo, :phone, :address, :inserted_at]}

  @required_attrs ~w{
      ref
      name
      logo
      email
      phone
      address
    }a

  schema "businesses" do
    field :ref, :string
    field :name, :string
    field :logo, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    belongs_to(:user, Account.User)

    timestamps()
  end

  def changeset(business, attrs) do
    business
    |> cast(attrs, @required_attrs)
    |> validate_required_fields()
    |> validate_unique_business_name(attrs)
  end

  defp validate_required_fields(changeset) do
    changeset
    |> validate_required([:ref], message: "Reference os required")
    |> validate_required([:name], message: "Business name is required")

    # |> validate_required([:email], message: "Contact name is required")
    # |> validate_required([:phone], message: "Contact name is required")
    # |> validate_required([:logo], message: "Logo is required")
    # |> validate_required([:address], message: "Contact name is required")
  end

  defp validate_unique_business_name(changeset, %{"nuban" => nuban, "user_id" => user_id}) do
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
