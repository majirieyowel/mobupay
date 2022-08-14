defmodule Mobupay.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    # Mobupay.TransactionFundingSourceEnum.create_type()

    create table(:transactions) do
      # used by the system - longer
      add(:ref, :string, null: false)
      # used by the user for issues - shorter
      add(:customer_ref, :string, null: false)
      add(:callback_hash, :string)
      add(:amount, :integer, null: false)
      add(:type, :transaction_type, null: false)
      add(:status, :transaction_status, null: false)
      add(:msisdn, :string, null: false)
      add(:narration, :string)
      add(:ip_address, :string, null: false)
      add(:device, :string, null: false)
      # add :funding_source, :string, null: false

      timestamps()
    end

    create(unique_index(:transactions, :ref))
    create(unique_index(:transactions, :callback_hash))
  end
end
