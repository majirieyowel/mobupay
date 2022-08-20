defmodule Mobupay.Repo.Migrations.CreatePaymentChannelLogs do
  use Ecto.Migration

  def change do
    create table(:payment_channel_logs) do
      add(:transaction_id, references(:transactions, on_delete: :delete_all))
      add :payment_channel, :string, null: false
      add :amount, :integer, null: false
      add :bank, :string
      add :card_type, :string
      add :country_code, :string
      add :exp_month, :string
      add :exp_year, :string
      add :last4, :string
      add :bin, :string

      timestamps()
    end

    create(index(:payment_channel_logs, [:transaction_id]))
  end
end
