defmodule Sheglow.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :position, :integer
    field :title, :string
    field :image, :string
    field :slug, :string
    field :is_active, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:title, :slug, :position, :image, :is_active])
    |> validate_required([:title, :slug, :position, :is_active])
  end
end
