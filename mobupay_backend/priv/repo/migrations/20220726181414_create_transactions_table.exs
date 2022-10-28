defmodule Mobupay.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    Mobupay.TransactionStatusEnum.create_type()
    Mobupay.TransactionPaymentChannelEnum.create_type()

    create table(:transactions) do
      add(:ref, :string, null: false)
      add(:from_ref, :string, null: false)
      add(:to_ref, :string, null: false)
      add(:amount, :integer, null: false)
      add(:status, :transaction_status, null: false)
      add(:payment_channel, :payment_channel, null: true)
      add(:from_msisdn, :string, null: false)
      add(:to_msisdn, :string, null: false)
      add(:narration, :string)
      add(:ip_address, :string, null: false)
      add(:device, :string, null: false)
      add(:is_visible, :boolean, default: true)

      timestamps()
    end

    create(unique_index(:transactions, :ref))
  end
end
