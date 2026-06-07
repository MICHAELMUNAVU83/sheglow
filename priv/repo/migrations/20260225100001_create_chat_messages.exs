defmodule Sheglow.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :chat_session_id, references(:chat_sessions, on_delete: :delete_all, type: :binary_id), null: false
      add :sender, :string, null: false
      add :content, :text
      add :message_type, :string, default: "text", null: false

      add :suggested_product_id, references(:products, on_delete: :nilify_all)
      add :suggested_product_name, :string
      add :suggested_product_price, :decimal, precision: 12, scale: 2
      add :suggested_product_image, :string
      add :suggested_product_slug, :string

      add :read_by_admin, :boolean, default: false, null: false
      add :read_by_visitor, :boolean, default: false, null: false

      timestamps(updated_at: false)
    end

    create index(:chat_messages, [:chat_session_id])
    create index(:chat_messages, [:inserted_at])
  end
end
