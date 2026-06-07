defmodule Sheglow.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :phone, :string
      add :address, :text
      add :order_count, :integer, null: false, default: 0
      add :total_spent, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:customers, [:email])
    create index(:customers, [:inserted_at])
  end
end
