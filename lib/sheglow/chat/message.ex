defmodule Sheglow.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_messages" do
    field :sender, :string
    field :content, :string
    field :message_type, :string, default: "text"

    field :suggested_product_id, :integer
    field :suggested_product_name, :string
    field :suggested_product_price, :decimal
    field :suggested_product_image, :string
    field :suggested_product_slug, :string

    field :read_by_admin, :boolean, default: false
    field :read_by_visitor, :boolean, default: false

    belongs_to :chat_session, Sheglow.Chat.Session

    timestamps(updated_at: false)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [
      :chat_session_id,
      :sender,
      :content,
      :message_type,
      :suggested_product_id,
      :suggested_product_name,
      :suggested_product_price,
      :suggested_product_image,
      :suggested_product_slug,
      :read_by_admin,
      :read_by_visitor
    ])
    |> validate_required([:chat_session_id, :sender])
    |> validate_inclusion(:sender, ["visitor", "admin"])
    |> validate_inclusion(:message_type, ["text", "product_suggestion"])
  end
end
