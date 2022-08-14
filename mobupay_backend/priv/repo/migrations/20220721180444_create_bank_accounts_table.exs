defmodule Mobupay.Repo.Migrations.CreateBankAccountsTable do
  use Ecto.Migration

  def change do
    create table(:bank_accounts) do
      add(:ref, :string)
      add(:nuban, :string)
      add(:name, :string)
      add(:bank_name, :string)
      add(:currency, :string)
      add(:cbn_code, :string)
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:bank_accounts, [:user_id]))
  end
end
