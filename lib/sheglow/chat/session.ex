defmodule Sheglow.Chat.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_sessions" do
    field :visitor_id, :string
    field :visitor_name, :string
    field :product_id, :integer
    field :product_name, :string
    field :product_slug, :string
    field :status, :string, default: "open"
    field :last_message_at, :utc_datetime

    has_many :messages, Sheglow.Chat.Message, foreign_key: :chat_session_id

    timestamps()
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :visitor_id,
      :visitor_name,
      :product_id,
      :product_name,
      :product_slug,
      :status,
      :last_message_at
    ])
    |> validate_required([:visitor_id])
    |> validate_inclusion(:status, ["open", "active", "closed"])
  end
end
