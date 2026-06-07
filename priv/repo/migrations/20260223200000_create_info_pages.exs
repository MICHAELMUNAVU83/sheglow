defmodule Sheglow.Repo.Migrations.CreateInfoPages do
  use Ecto.Migration

  def change do
    create table(:info_pages) do
      add :slug, :string, null: false
      add :title, :string, null: false
      add :icon, :string
      add :content, :text
      add :meta_description, :string
      add :is_active, :boolean, null: false, default: true
      add :position, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:info_pages, [:slug])
    create index(:info_pages, [:is_active])
  end
end
