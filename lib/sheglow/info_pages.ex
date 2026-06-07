defmodule Sheglow.InfoPages do
  @moduledoc "Context for customer-facing info pages (How to Order, Size Guide, etc.)"

  import Ecto.Query
  alias Sheglow.Repo
  alias Sheglow.InfoPages.InfoPage

  def list_info_pages do
    from(p in InfoPage, order_by: [asc: p.position, asc: p.title])
    |> Repo.all()
  end

  def list_active_info_pages do
    from(p in InfoPage, where: p.is_active == true, order_by: [asc: p.position])
    |> Repo.all()
  end

  def get_info_page!(id), do: Repo.get!(InfoPage, id)

  def get_by_slug(slug) do
    Repo.get_by(InfoPage, slug: slug, is_active: true)
  end

  def create_info_page(attrs \\ %{}) do
    %InfoPage{}
    |> InfoPage.changeset(attrs)
    |> Repo.insert()
  end

  def update_info_page(%InfoPage{} = page, attrs) do
    page
    |> InfoPage.changeset(attrs)
    |> Repo.update()
  end

  def delete_info_page(%InfoPage{} = page), do: Repo.delete(page)

  def count_info_pages, do: Repo.aggregate(InfoPage, :count)

  def change_info_page(%InfoPage{} = page, attrs \\ %{}) do
    InfoPage.changeset(page, attrs)
  end
end
