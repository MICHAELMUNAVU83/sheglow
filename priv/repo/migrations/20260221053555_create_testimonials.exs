defmodule Sheglow.Repo.Migrations.CreateTestimonials do
  use Ecto.Migration

  def change do
    create table(:testimonials) do
      add :name, :string
      add :rating, :integer
      add :image, :string
      add :body, :text
      add :is_active, :boolean, default: false, null: false
      add :position, :integer
      add :product_id, references(:products, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:testimonials, [:product_id])
  end
end
