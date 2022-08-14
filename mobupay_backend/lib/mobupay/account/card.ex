defmodule Mobupay.Account.Card do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Account.User

  @derive {Jason.Encoder,
           only: [:ref, :bank, :card_type, :country_code, :exp_month, :exp_year, :last4, :bin]}

  @required_attrs ~w{
      ref
      authorization_code
      bank
      card_type
      country_code
      exp_month
      exp_year
      last4
      bin
    }a

  schema "cards" do
    field(:ref, :string)
    field(:authorization_code, :string)
    field(:bank, :string)
    field(:card_type, :string)
    field(:country_code, :string)
    field(:exp_month, :string)
    field(:exp_year, :string)
    field(:last4, :string)
    field(:bin, :string)
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(card, attrs \\ %{}) do
    card
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
