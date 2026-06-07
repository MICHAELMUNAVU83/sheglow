defmodule Sheglow.Repo.Migrations.CreateBundleItems do
  use Ecto.Migration

  def change do
    create table(:bundle_items) do
      add :bundle_id, references(:bundles, on_delete: :nothing)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:bundle_items, [:bundle_id])
    create index(:bundle_items, [:product_id])
  end
end
