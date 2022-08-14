defmodule Mobupay.Repo.Migrations.CreateLedgersTable do
  use Ecto.Migration

  def change do

    create table(:ledgers) do
      add(:transaction_id, references(:transactions, on_delete: :delete_all))
      add :msisdn, :string, null: false
      add :amount, :integer, null: false

      timestamps()
    end
  end
end
