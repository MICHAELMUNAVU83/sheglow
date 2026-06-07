defmodule SheglowWeb.InfoLive.Show do
  use SheglowWeb, :live_view

  alias Sheglow.InfoPages
  alias Sheglow.Shop

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    case InfoPages.get_by_slug(slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Page not found")
         |> push_navigate(to: "/")}

      page ->
        {:ok,
         socket
         |> assign(:page_title, page.title)
         |> assign(:meta_description, page.meta_description || page.title)
         |> assign(:page, page)
         |> assign(:all_pages, InfoPages.list_active_info_pages())
         |> assign(:nav_collections, Shop.list_collections_for_display())}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="page-typography min-h-screen bg-white">
      <.navbar collections={@nav_collections} />

      <%!-- Hero banner --%>
      <div class="bg-gradient-to-r from-[#C8001F] to-red-800 px-4 py-14 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-3xl text-center">
          <p class="text-sm font-semibold uppercase tracking-widest text-red-200">
            SheGlow UG
          </p>
          <h1 class="mt-3 text-3xl font-bold text-white sm:text-4xl lg:text-5xl">
            {@page.title}
          </h1>
        </div>
      </div>

      <%!-- Main layout: sidebar nav + content --%>
      <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div class="flex flex-col gap-10 lg:flex-row lg:gap-16">
          <%!-- Sidebar: other pages --%>
          <aside class="w-full flex-shrink-0 lg:w-56">
            <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">
              Customer Care
            </p>
            <nav class="mt-4 space-y-1">
              <%= for p <- @all_pages do %>
                <a
                  href={"/info/#{p.slug}"}
                  class={"flex items-center gap-2.5 rounded-xl px-3 py-2.5 text-sm font-medium transition #{if p.id == @page.id, do: "bg-[#C8001F] text-white shadow-sm", else: "text-gray-600 hover:bg-gray-100 hover:text-gray-900"}"}
                >
                  <%= if p.icon do %>
                    <span class="text-base">{p.icon}</span>
                  <% end %>
                  {p.title}
                </a>
              <% end %>
            </nav>

            <div class="mt-8 rounded-2xl bg-gray-50 p-5">
              <p class="text-sm font-semibold text-gray-900">Still need help?</p>
              <p class="mt-1 text-xs text-gray-500">
                Chat with us directly on WhatsApp.
              </p>
              <a
                href="https://wa.me/256742013968"
                target="_blank"
                rel="noopener noreferrer"
                class="mt-4 flex items-center justify-center gap-2 rounded-xl bg-green-500 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-green-600"
              >
                <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
                </svg>
                WhatsApp Us
              </a>
            </div>
          </aside>

          <%!-- Page content --%>
          <article class="min-w-0 flex-1">
            <div class="prose prose-gray max-w-none">
              {Phoenix.HTML.raw(render_content(@page.content))}
            </div>

            <%!-- CTA footer --%>
            <div class="mt-12 flex flex-col items-start gap-4 border-t border-gray-100 pt-8 sm:flex-row sm:items-center sm:justify-between">
              <p class="text-sm text-gray-500">
                Questions? We're always happy to help.
              </p>
              <a
                href="https://wa.me/256742013968"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-2 rounded-full bg-[#C8001F] px-6 py-2.5 text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
              >
                Contact Us on WhatsApp
              </a>
            </div>
          </article>
        </div>
      </div>

      <.footer />
    </div>
    """
  end

  # Converts simple markdown-like text to HTML paragraphs.
  # Supports:
  #   ## Heading      → <h2>
  #   ### Heading     → <h3>
  #   **bold**        → <strong>
  #   - list item     → <ul><li>
  #   blank line      → paragraph break
  defp render_content(nil), do: "<p class=\"text-gray-400 italic\">No content yet.</p>"

  defp render_content(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> parse_lines([])
    |> Enum.join("\n")
  end

  defp parse_lines([], acc), do: Enum.reverse(acc)

  defp parse_lines(["## " <> heading | rest], acc) do
    parse_lines(rest, [
      "<h2 class=\"text-2xl font-bold text-gray-900 mt-8 mb-3\">#{escape(heading)}</h2>" | acc
    ])
  end

  defp parse_lines(["### " <> heading | rest], acc) do
    parse_lines(rest, [
      "<h3 class=\"text-lg font-semibold text-gray-800 mt-6 mb-2\">#{escape(heading)}</h3>" | acc
    ])
  end

  defp parse_lines(["" | rest], acc) do
    parse_lines(rest, acc)
  end

  defp parse_lines(lines, acc) do
    {list_items, rest} = Enum.split_while(lines, &String.starts_with?(&1, "- "))

    if list_items != [] do
      items_html =
        list_items
        |> Enum.map(fn "- " <> text -> "<li class=\"ml-4\">#{inline(text)}</li>" end)
        |> Enum.join("\n")

      parse_lines(rest, [
        "<ul class=\"list-disc space-y-1.5 pl-4 text-gray-700\">#{items_html}</ul>" | acc
      ])
    else
      {para_lines, rest} =
        Enum.split_while(
          lines,
          &(&1 != "" and not String.starts_with?(&1, "## ") and
              not String.starts_with?(&1, "### ") and not String.starts_with?(&1, "- "))
        )

      if para_lines != [] do
        text = para_lines |> Enum.join(" ") |> inline()
        parse_lines(rest, ["<p class=\"text-gray-700 leading-relaxed\">#{text}</p>" | acc])
      else
        parse_lines(rest, acc)
      end
    end
  end

  defp inline(text) do
    text
    |> escape()
    |> String.replace(~r/\*\*(.+?)\*\*/, "<strong>\\1</strong>")
    |> String.replace(~r/\*(.+?)\*/, "<em>\\1</em>")
  end

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
