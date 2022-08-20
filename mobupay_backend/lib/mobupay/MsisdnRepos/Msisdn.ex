defmodule Mobupay.MsisdnRepos.Msisdn do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "msisdns" do
    field(:country_code, :string)
    field(:msisdn, :string)

    timestamps()
  end

  @doc false
  def changeset(bank_account, attrs) do
    bank_account
    |> cast(attrs, [:country_code, :msisdn])
    |> validate_required([:country_code, :msisdn])
  end
end
