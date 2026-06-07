defmodule Sheglow.Repo.Migrations.CreateChatSessions do
  use Ecto.Migration

  def change do
    create table(:chat_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visitor_id, :string, null: false
      add :visitor_name, :string
      add :product_id, references(:products, on_delete: :nilify_all)
      add :product_name, :string
      add :product_slug, :string
      add :status, :string, default: "open", null: false
      add :last_message_at, :utc_datetime

      timestamps()
    end

    create index(:chat_sessions, [:visitor_id])
    create index(:chat_sessions, [:status])
    create index(:chat_sessions, [:last_message_at])
  end
end
