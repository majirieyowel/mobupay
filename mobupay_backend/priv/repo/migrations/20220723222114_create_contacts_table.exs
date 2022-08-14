defmodule Mobupay.Repo.Migrations.CreateContactsTable do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add(:ref, :string)
      add(:msisdn, :string)
      add(:name, :string)
      add(:country_code, :string)
      add(:frequency, :integer, default: 0)
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:contacts, [:user_id]))
  end
end
