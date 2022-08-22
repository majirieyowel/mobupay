defmodule Mobupay.Repo.Migrations.CreateWithdrawalsTable do
  use Ecto.Migration

  def change do
    Mobupay.WithdrawalStatusEnum.create_type()

    create table(:withdrawals) do
      add(:ref, :string, null: false)
      add(:amount, :integer, null: false)
      add(:status, :withdrawal_status, null: false)
      add(:bank_account_number, :string, null: false)
      add(:bank_name, :string, null: false)
      add(:ip_address, :string, null: false)
      add(:device, :string, null: false)
      add(:user_id, references(:users, on_delete: :delete_all))
      timestamps()
    end

    create(index(:withdrawals, [:user_id]))
    create(unique_index(:withdrawals, :ref))
  end
end
