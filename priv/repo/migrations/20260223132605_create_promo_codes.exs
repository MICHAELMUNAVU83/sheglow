defmodule Sheglow.Repo.Migrations.CreatePromoCodes do
  use Ecto.Migration

  def change do
    create table(:promo_codes) do
      add :code,              :string,  null: false
      add :description,       :string
      add :influencer_name,   :string
      add :discount_percent,  :integer, null: false
      add :is_active,         :boolean, null: false, default: true
      add :usage_count,       :integer, null: false, default: 0
      add :max_uses,          :integer  # null = unlimited
      add :expires_at,        :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:promo_codes, [:code])
    create index(:promo_codes, [:is_active])

    # Add promo tracking to orders
    alter table(:orders) do
      add :promo_code,       :string
      add :discount_amount,  :integer, null: false, default: 0
    end
  end
end
