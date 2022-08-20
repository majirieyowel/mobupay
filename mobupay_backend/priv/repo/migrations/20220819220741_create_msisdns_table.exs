defmodule Mobupay.Repo.Migrations.CreateMsisdnsTable do
  use Ecto.Migration

  def change do
    create table(:msisdns) do
      add :msisdn, :string, null: false
      add :country_code, :string, null: false
      timestamps()
    end
  end
end
