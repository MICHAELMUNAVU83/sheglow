defmodule Sheglow.InfoPages.InfoPage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "info_pages" do
    field :slug, :string
    field :title, :string
    field :icon, :string
    field :content, :string
    field :meta_description, :string
    field :is_active, :boolean, default: true
    field :position, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:slug, :title, :icon, :content, :meta_description, :is_active, :position])
    |> validate_required([:slug, :title])
    |> validate_length(:title, max: 120)
    |> validate_length(:meta_description, max: 160)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "only lowercase letters, numbers and hyphens")
    |> unique_constraint(:slug)
  end
end
