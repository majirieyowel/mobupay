defmodule Mobupay.Account.Contact do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Account

  @derive {Jason.Encoder, only: [:ref, :name, :msisdn, :inserted_at]}

  @required_attrs ~w{
      ref
      name
      msisdn
      country_code
    }a

  schema "contacts" do
    field(:ref, :string)
    field(:name, :string)
    field(:msisdn, :string)
    field(:country_code, :string)
    field(:frequency, :integer)
    belongs_to(:user, Account.User)

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, @required_attrs)
    |> validate_required_fields()
    |> validate_unique_msisdn(attrs)
    |> validate_unique_name(attrs)
  end

  defp validate_required_fields(changeset) do
    changeset
    |> validate_required([:country_code], message: "Country is required")
    |> validate_required([:msisdn], message: "Phone number is required")
    |> validate_required([:name], message: "Contact name is required")
  end

  defp validate_unique_msisdn(changeset, %{"msisdn" => msisdn, "user_id" => user_id}) do
    case Account.msisdn_exists?(user_id, msisdn) do
      true ->
        add_error(
          changeset,
          :msisdn,
          "Contact already exists"
        )

      _ ->
        changeset
    end
  end

  defp validate_unique_name(changeset, %{"name" => name, "user_id" => user_id}) do
    case Account.contact_name_exists?(user_id, name) do
      true ->
        add_error(
          changeset,
          :name,
          "Contact name (#{name}) already exists"
        )

      _ ->
        changeset
    end
  end
end
