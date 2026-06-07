defmodule Sheglow.Repo.Migrations.AddRoleAndLastSignedInToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, null: false, default: "member"
      add :name, :string
      add :last_signed_in_at, :utc_datetime
    end
  end
end
