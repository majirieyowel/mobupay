defmodule Mobupay.Repo.Migrations.CreateCardsTable do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :ref, :string, null: false
      add :authorization_code, :string, null: false
      add :bank, :string, null: false
      add :card_type, :string, null: false
      add :country_code, :string, null: false
      add :exp_month, :string, null: false
      add :exp_year, :string, null: false
      add :last4, :string, null: false
      add :bin, :string, null: false
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:cards, [:user_id]))
    create unique_index(:cards, :ref)
  end
end
