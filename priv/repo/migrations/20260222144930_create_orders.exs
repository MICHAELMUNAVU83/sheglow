defmodule Sheglow.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :reference, :string, null: false
      add :email, :string, null: false
      add :name, :string, null: false
      add :phone, :string
      add :address, :text
      add :total_amount, :integer, null: false, default: 0
      add :status, :string, null: false, default: "pending"
      add :items, {:array, :map}, null: false, default: []

      timestamps(type: :utc_datetime)
    end

    create unique_index(:orders, [:reference])
    create index(:orders, [:status])
  end
end
