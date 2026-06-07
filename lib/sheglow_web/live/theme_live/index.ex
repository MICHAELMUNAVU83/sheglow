defmodule SheglowWeb.ThemeLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.SiteSettings
  alias Sheglow.SiteSettings.Setting

  @impl true
  def mount(_params, _session, socket) do
    settings = SiteSettings.get()
    changeset = Setting.changeset(settings, %{})

    {:ok,
     socket
     |> assign(:page_title, "Theme & Branding")
     |> assign(:current_path, "/admin/theme")
     |> assign(:settings, settings)
     |> assign(:form, to_form(changeset, as: "settings"))
     |> assign(:save_status, nil)
     |> assign(:active_tab, "brand")}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  @impl true
  def handle_event("pick_color", params, socket) do
    color = Map.get(params, "color", Map.get(params, "value", "#C8001F"))

    changeset =
      socket.assigns.settings
      |> Setting.changeset(%{primary_color: color})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "settings"))}
  end

  @impl true
  def handle_event("validate", %{"settings" => params}, socket) do
    changeset =
      socket.assigns.settings
      |> Setting.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "settings"))}
  end

  @impl true
  def handle_event("save", %{"settings" => params}, socket) do
    case SiteSettings.update(params) do
      {:ok, updated} ->
        changeset = Setting.changeset(updated, %{})

        {:noreply,
         socket
         |> assign(:settings, updated)
         |> assign(:form, to_form(changeset, as: "settings"))
         |> assign(:save_status, :ok)
         |> put_flash(:info, "Theme saved — refresh the public site to see changes.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: "settings"))
         |> assign(:save_status, :error)}
    end
  end

  # ── Font helpers ────────────────────────────────────────────────────────────

  defp font_options, do: SiteSettings.font_options()

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- Header --%>
      <div class="mb-8 flex items-start justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Theme & Branding</h1>
          <p class="mt-1 text-sm text-gray-500">
            Customise colors, fonts and site identity. Changes apply immediately after saving.
          </p>
        </div>
        <a
          href="/"
          target="_blank"
          class="flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-2 text-sm font-medium text-gray-600 shadow-sm transition hover:border-[#C8001F]/40 hover:text-[#C8001F]"
        >
          <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
            />
          </svg>
          Preview site
        </a>
      </div>

      <%!-- Tabs --%>
      <div class="mb-6 flex gap-1 rounded-xl border border-gray-200 bg-gray-50 p-1 w-fit">
        <%= for {id, label, icon} <- [{"brand", "Brand Identity", "🏷️"}, {"colors", "Colors", "🎨"}, {"fonts", "Typography", "🔤"}, {"contact", "Contact & Social", "📬"}] do %>
          <button
            type="button"
            phx-click="switch_tab"
            phx-value-tab={id}
            class={"rounded-lg px-4 py-2 text-sm font-medium transition #{if @active_tab == id, do: "bg-white shadow-sm text-gray-900", else: "text-gray-500 hover:text-gray-700"}"}
          >
            {icon} {label}
          </button>
        <% end %>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="save">
        <%!-- ── Brand Identity ── --%>
        <div class={if @active_tab == "brand", do: "block", else: "hidden"}>
          <div class="overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm">
            <div class="border-b border-gray-100 px-6 py-4">
              <h2 class="text-base font-semibold text-gray-900">Brand Identity</h2>
              <p class="mt-0.5 text-xs text-gray-400">
                Site name, tagline and logo shown across the storefront.
              </p>
            </div>
            <div class="space-y-5 p-6">
              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                    Site Name <span class="text-red-500">*</span>
                  </label>
                  <.input field={@form[:site_name]} type="text" placeholder="e.g. SheGlow UG" />
                </div>
                <div>
                  <label class="mb-1.5 block text-sm font-semibold text-gray-700">Tagline</label>
                  <.input
                    field={@form[:site_tagline]}
                    type="text"
                    placeholder="e.g. Healthy Skin. Confident You."
                  />
                </div>
              </div>

              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Logo URL</label>
                <.input
                  field={@form[:logo_url]}
                  type="text"
                  placeholder="/images/sheglow-logo.png or https://..."
                />
                <%= if @settings.logo_url && @settings.logo_url != "" do %>
                  <div class="mt-3 flex items-center gap-3 rounded-xl border border-gray-100 bg-gray-50 px-4 py-3">
                    <img
                      src={@settings.logo_url}
                      alt="Logo preview"
                      class="h-10 w-10 rounded-lg object-contain"
                    />
                    <span class="text-xs text-gray-500">Current logo</span>
                  </div>
                <% end %>
              </div>

              <%!-- Live preview card --%>
              <div class="rounded-2xl border border-gray-100 bg-gray-50 p-5">
                <p class="mb-3 text-xs font-semibold uppercase tracking-widest text-gray-400">
                  Preview
                </p>
                <div class="flex items-center gap-3">
                  <div class="h-10 w-10 overflow-hidden rounded-full bg-gray-200">
                    <%= if @settings.logo_url && @settings.logo_url != "" do %>
                      <img src={@settings.logo_url} class="h-full w-full object-cover" alt="" />
                    <% else %>
                      <div class="flex h-full w-full items-center justify-center text-lg font-bold text-gray-400">
                        {String.first(@settings.site_name || "K")}
                      </div>
                    <% end %>
                  </div>
                  <div>
                    <p class="font-bold text-gray-900">{@settings.site_name}</p>
                    <p class="text-xs text-gray-500">{@settings.site_tagline}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <%!-- ── Colors ── --%>
        <div class={if @active_tab == "colors", do: "block", else: "hidden"}>
          <div class="overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm">
            <div class="border-b border-gray-100 px-6 py-4">
              <h2 class="text-base font-semibold text-gray-900">Colors</h2>
              <p class="mt-0.5 text-xs text-gray-400">
                Primary brand color used for buttons, links, and accents.
              </p>
            </div>
            <div class="space-y-6 p-6">
              <% current_color = Phoenix.HTML.Form.input_value(@form, :primary_color) %>
              <div>
                <label class="mb-3 block text-sm font-semibold text-gray-700">
                  Primary Brand Color
                </label>
                <div class="flex items-center gap-4">
                  <%!-- Native color picker — phx-change fires a server event --%>
                  <input
                    type="color"
                    value={current_color}
                    phx-change="pick_color"
                    name="color"
                    class="h-14 w-20 cursor-pointer rounded-xl border border-gray-200 p-1"
                  />
                  <div class="flex-1">
                    <.input
                      field={@form[:primary_color]}
                      type="text"
                      placeholder="#C8001F"
                      phx-debounce="300"
                    />
                    <p class="mt-1 text-xs text-gray-400">
                      Type a hex color or use the picker / presets below.
                    </p>
                  </div>
                </div>
              </div>

              <%!-- Preset palettes — each fires pick_color via phx-click --%>
              <div class="rounded-2xl border border-gray-100 bg-gray-50 p-5">
                <p class="mb-4 text-xs font-semibold uppercase tracking-widest text-gray-400">
                  Preset Palettes
                </p>
                <div class="flex flex-wrap gap-3">
                  <%= for {name, hex} <- [
                    {"Crimson", "#C8001F"},
                    {"Royal Blue", "#1D4ED8"},
                    {"Emerald", "#059669"},
                    {"Violet", "#7C3AED"},
                    {"Amber", "#D97706"},
                    {"Rose", "#E11D48"},
                    {"Slate", "#475569"},
                    {"Teal", "#0F766E"},
                    {"Indigo", "#4338CA"},
                    {"Fuchsia", "#A21CAF"}
                  ] do %>
                    <button
                      type="button"
                      title={name}
                      phx-click="pick_color"
                      phx-value-color={hex}
                      class={"group flex flex-col items-center gap-1 #{if current_color == hex, do: "ring-2 ring-offset-2 ring-gray-400 rounded-full"}"}
                    >
                      <span
                        class="h-8 w-8 rounded-full border-2 border-white shadow-md transition group-hover:scale-110"
                        style={"background-color: #{hex};"}
                      />
                      <span class="text-[10px] text-gray-500">{name}</span>
                    </button>
                  <% end %>
                </div>
              </div>

              <%!-- Live preview — updates instantly on every pick --%>
              <div class="rounded-2xl border border-gray-100 bg-gray-50 p-5">
                <p class="mb-3 text-xs font-semibold uppercase tracking-widest text-gray-400">
                  Preview
                </p>
                <div class="flex flex-wrap items-center gap-3">
                  <button
                    type="button"
                    class="rounded-xl px-5 py-2 text-sm font-semibold text-white"
                    style={"background-color: #{current_color};"}
                  >
                    Primary Button
                  </button>
                  <span class="text-sm font-semibold" style={"color: #{current_color};"}>
                    Brand text link →
                  </span>
                  <span
                    class="rounded-full px-3 py-1 text-xs font-semibold text-white"
                    style={"background-color: #{current_color};"}
                  >
                    Badge
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <%!-- ── Typography ── --%>
        <div class={if @active_tab == "fonts", do: "block", else: "hidden"}>
          <div class="overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm">
            <div class="border-b border-gray-100 px-6 py-4">
              <h2 class="text-base font-semibold text-gray-900">Typography</h2>
              <p class="mt-0.5 text-xs text-gray-400">
                Choose Google Fonts for body text, headings and your brand script.
              </p>
            </div>
            <div class="space-y-6 p-6">
              <%!-- Body font --%>
              <div>
                <label class="mb-2 block text-sm font-semibold text-gray-700">
                  Body / Paragraph Font
                </label>
                <div class="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
                  <%= for font <- font_options().body do %>
                    <label class={"flex cursor-pointer items-center gap-3 rounded-xl border-2 p-3 transition #{if Phoenix.HTML.Form.input_value(@form, :font_body) == font, do: "border-[#C8001F] bg-[#C8001F]/5", else: "border-gray-200 hover:border-gray-300"}"}>
                      <input
                        type="radio"
                        name="settings[font_body]"
                        value={font}
                        checked={Phoenix.HTML.Form.input_value(@form, :font_body) == font}
                        class="h-4 w-4 accent-[#C8001F]"
                      />
                      <div>
                        <p class="text-sm font-semibold text-gray-800">{font}</p>
                        <p class="text-xs text-gray-500" style={"font-family: '#{font}', sans-serif;"}>
                          The quick brown fox
                        </p>
                      </div>
                    </label>
                  <% end %>
                </div>
              </div>

              <%!-- Heading font --%>
              <div>
                <label class="mb-2 block text-sm font-semibold text-gray-700">
                  Heading Font (H1–H4)
                </label>
                <div class="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
                  <%= for font <- font_options().heading do %>
                    <label class={"flex cursor-pointer items-center gap-3 rounded-xl border-2 p-3 transition #{if Phoenix.HTML.Form.input_value(@form, :font_heading) == font, do: "border-[#C8001F] bg-[#C8001F]/5", else: "border-gray-200 hover:border-gray-300"}"}>
                      <input
                        type="radio"
                        name="settings[font_heading]"
                        value={font}
                        checked={Phoenix.HTML.Form.input_value(@form, :font_heading) == font}
                        class="h-4 w-4 accent-[#C8001F]"
                      />
                      <div>
                        <p class="text-sm font-semibold text-gray-800">{font}</p>
                        <p class="text-base text-gray-600" style={"font-family: '#{font}', serif;"}>
                          Heading Style
                        </p>
                      </div>
                    </label>
                  <% end %>
                </div>
              </div>

              <%!-- Script / Logo font --%>
              <div>
                <label class="mb-2 block text-sm font-semibold text-gray-700">
                  Script / Logo Font
                </label>
                <div class="grid gap-2 sm:grid-cols-2 lg:grid-cols-4">
                  <%= for font <- font_options().script do %>
                    <label class={"flex cursor-pointer items-center gap-3 rounded-xl border-2 p-3 transition #{if Phoenix.HTML.Form.input_value(@form, :font_script) == font, do: "border-[#C8001F] bg-[#C8001F]/5", else: "border-gray-200 hover:border-gray-300"}"}>
                      <input
                        type="radio"
                        name="settings[font_script]"
                        value={font}
                        checked={Phoenix.HTML.Form.input_value(@form, :font_script) == font}
                        class="h-4 w-4 accent-[#C8001F]"
                      />
                      <div>
                        <p class="text-sm font-semibold text-gray-800">{font}</p>
                        <p class="text-lg" style={"font-family: '#{font}', cursive;"}>
                          Sheglow
                        </p>
                      </div>
                    </label>
                  <% end %>
                </div>
              </div>

              <%!-- Note: fonts load in browser from Google; previews are approximate in admin --%>
              <p class="rounded-xl bg-amber-50 px-4 py-3 text-xs text-amber-700">
                💡 Font previews here require the fonts to be cached in your browser. The public storefront always loads the selected fonts fresh.
              </p>
            </div>
          </div>
        </div>

        <%!-- ── Contact & Social ── --%>
        <div class={if @active_tab == "contact", do: "block", else: "hidden"}>
          <div class="overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm">
            <div class="border-b border-gray-100 px-6 py-4">
              <h2 class="text-base font-semibold text-gray-900">Contact & Social</h2>
              <p class="mt-0.5 text-xs text-gray-400">
                These appear in the footer and contact sections.
              </p>
            </div>
            <div class="space-y-5 p-6">
              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                    Support Email
                  </label>
                  <.input
                    field={@form[:support_email]}
                    type="email"
                    placeholder="support@yourstore.com"
                  />
                </div>
                <div>
                  <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                    WhatsApp Number
                  </label>
                  <.input field={@form[:whatsapp_number]} type="text" placeholder="+254 700 000 000" />
                </div>
              </div>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Instagram URL</label>
                <.input
                  field={@form[:instagram_url]}
                  type="text"
                  placeholder="https://instagram.com/yourbrand"
                />
              </div>
            </div>
          </div>
        </div>

        <%!-- Save bar — always visible --%>
        <div class="mt-6 flex items-center gap-4 rounded-2xl border border-gray-200 bg-white px-6 py-4 shadow-sm">
          <button
            type="submit"
            class="rounded-xl bg-[#C8001F] px-6 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-[var(--brand-primary-dark)]"
          >
            Save Changes
          </button>
          <%= if @save_status == :ok do %>
            <span class="flex items-center gap-1.5 text-sm font-medium text-green-600">
              <svg
                class="h-4 w-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                stroke-width="2"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
              </svg>
              Saved!
            </span>
          <% end %>
          <p class="ml-auto text-xs text-gray-400">
            Changes take effect on the next page load for visitors.
          </p>
        </div>
      </.form>
    </div>
    """
  end
end
