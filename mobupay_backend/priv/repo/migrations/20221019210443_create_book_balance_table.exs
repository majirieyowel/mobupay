defmodule Mobupay.Repo.Migrations.CreateBookBalanceTable do
  use Ecto.Migration

  def change do
    create table(:book_balance) do
      add(:transaction_id, references(:transactions, on_delete: :delete_all))
      add :msisdn, :string, null: false
      add :amount, :integer, null: false

      timestamps()
    end

    create(index(:book_balance, [:msisdn]))
  end
end
