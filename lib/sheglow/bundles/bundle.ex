defmodule Sheglow.Bundles.Bundle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bundles" do
    field :description, :string
    field :title, :string
    field :image, :string
    field :is_active, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bundle, attrs) do
    bundle
    |> cast(attrs, [:title, :description, :image, :is_active])
    |> validate_required([:title, :description])
  end
end
