defmodule Mobupay.Repo.Migrations.AddWhatsappStateTable do
  use Ecto.Migration

  def change do
    create table(:whatsapp_state) do
      add(:msisdn, :string, null: false)
      add(:email, :string)
      add(:email_confirmation_token, :string)
      add(:email_confirmed_at, :utc_datetime)
      add(:has_onboarded, :boolean, null: false)
      add(:state, :string, null: false)
      add(:state_action, :string)
      add(:state_param, :json)
      add(:state_action_expiration, :utc_datetime)

      timestamps()
    end

    create(index(:whatsapp_state, [:msisdn]))
  end
end
