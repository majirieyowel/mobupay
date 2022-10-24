defmodule Mobupay.Repo.Migrations.CreateAccountBalanceTable do
  use Ecto.Migration

  def change do
    create table(:account_balance) do
      add(:transaction_id, references(:transactions, on_delete: :delete_all))
      add :msisdn, :string, null: false
      add :amount, :integer, null: false

      timestamps()
    end

    create(index(:account_balance, [:msisdn]))
  end
end
