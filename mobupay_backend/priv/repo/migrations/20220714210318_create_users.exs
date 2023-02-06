defmodule Mobupay.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :email_confirmation_token, :string
      add :email_confirmed_at, :utc_datetime
      add :msisdn, :string, null: false
      add :country, :string, null: true
      add :currency, :string, null: true
      add :ref, :string, null: false
      add :city, :string, null: true
      add :region, :string, null: true
      add :account_balance, :integer, null: true
      add :book_balance, :integer, null: true
      add :hashed_password, :string
      add :state, :string, null: false
      add :state_action, :string
      add :state_param, :json
      add :state_action_expiration, :utc_datetime
      add :language, :string
      add :has_onboarded, :boolean, null: false
      timestamps()
    end

    create unique_index(:users, :msisdn)
    create unique_index(:users, :ref)
  end
end
