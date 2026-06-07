defmodule Sheglow.Repo.Migrations.CreateProductVariants do
  use Ecto.Migration

  def change do
    create table(:product_variants) do
      add :color_name, :string
      add :color_hex, :string
      add :size, :string
      add :stock_quantity, :string
      add :product_id, references(:products, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
