defmodule Mobupay.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    Mobupay.TransactionTypeEnum.create_type()
    Mobupay.TransactionStatusEnum.create_type()

    create table(:users) do
      add :email, :string
      add :msisdn, :string, null: false
      add :country, :string, null: false
      add :ref, :string, null: false
      add :city, :string
      add :region, :string
      add :hashed_password, :string
      timestamps()
    end

    create unique_index(:users, :msisdn)
    create unique_index(:users, :ref)
  end
end
