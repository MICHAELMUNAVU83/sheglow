defmodule Sheglow.Repo.Migrations.AddContentFieldsToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :size_advice, :text
      add :shipping_returns, :text
    end
  end
end
