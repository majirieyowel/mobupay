defmodule Mobupay.Whatsapp.State do
  use Ecto.Schema
  import Ecto.Changeset

  schema "whatsapp_state" do
    field :email, :string
    field :email_confirmation_token, :string
    field :email_confirmed_at, :utc_datetime
    field :msisdn, :string
    field :has_onboarded, :boolean, default: false
    field :state, :string
    field :state_action, :string
    field :state_param, :map
    field :state_action_expiration, :utc_datetime

    timestamps()
  end

  def changeset(state, attrs) do
    state
    |> cast(attrs, [
      :email,
      :email_confirmation_token,
      :msisdn,
      :has_onboarded,
      :state,
      :state_action,
      :state_param,
      :state_action_expiration
    ])
    |> validate_required([:msisdn, :state])
  end
end
