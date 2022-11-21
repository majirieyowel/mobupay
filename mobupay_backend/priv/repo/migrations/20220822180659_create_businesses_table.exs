defmodule Mobupay.Repo.Migrations.CreateBusinessesTable do
  use Ecto.Migration

  def change do
    create table(:businesses) do
      add :ref, :string, null: false
      add :name, :string, null: false
      add :logo, :string
      add :address, :string
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:businesses, [:user_id]))
  end
end
