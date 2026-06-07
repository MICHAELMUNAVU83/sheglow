defmodule Sheglow.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :slug, :string
      add :description, :text
      add :base_price, :integer
      add :image, :string
      add :badge_label, :string
      add :badge_color, :string
      add :is_featured, :boolean, default: false, null: false
      add :is_bestseller, :boolean, default: false, null: false
      add :is_new_arrival, :boolean, default: false, null: false
      add :position, :integer
      add :status, :string
      add :collection_id, references(:collections, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:collection_id])
  end
end
