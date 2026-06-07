defmodule SheglowWeb.SidebarComponents do
  use Phoenix.Component
  use SheglowWeb, :verified_routes

  @doc """
  The main admin sidebar wrapper.

  ## Example
      <.admin_sidebar current_path={@current_path} counts={@counts} />
  """
  def admin_sidebar(assigns) do
    assigns =
      assigns
      |> assign_new(:counts, fn -> %{} end)
      |> assign_new(:current_path, fn -> "/" end)
      |> assign_new(:current_user, fn -> nil end)

    ~H"""
    <aside class="flex h-screen w-[220px] flex-shrink-0 flex-col border-r border-gray-200 bg-white xl:w-[240px]">
      <.sidebar_logo />

      <nav class="flex-1 overflow-y-auto px-3 py-4 space-y-0.5">
        <.nav_section label="Overview" />

        <.nav_item label="Dashboard" path={~p"/admin"} active={@current_path == "/admin"} icon="grid" />

        <.nav_item
          label="Orders"
          path={~p"/admin/orders"}
          active={String.starts_with?(@current_path, "/admin/orders")}
          icon="cart"
          badge={Map.get(@counts, :orders)}
          badge_variant={:default}
        />

        <.nav_divider />
        <.nav_section label="Catalogue" />

        <.nav_item
          label="Products"
          path={~p"/admin/products"}
          active={String.starts_with?(@current_path, "/admin/products")}
          icon="tag"
          badge={Map.get(@counts, :products)}
          badge_variant={:count}
        />

        <.nav_item
          label="Collections"
          path={~p"/admin/collections"}
          active={String.starts_with?(@current_path, "/admin/collections")}
          icon="layers"
          badge={Map.get(@counts, :collections)}
          badge_variant={:count}
        />

        <.nav_item
          label="Bundles"
          path={~p"/admin/bundles"}
          active={String.starts_with?(@current_path, "/admin/bundles")}
          icon="package"
          badge={Map.get(@counts, :bundles)}
          badge_variant={:count}
        />

        <.nav_item
          label="Testimonials"
          path={~p"/admin/testimonials"}
          active={String.starts_with?(@current_path, "/admin/testimonials")}
          icon="quote"
          badge={Map.get(@counts, :testimonials)}
          badge_variant={:count}
        />

        <.nav_divider />
        <.nav_section label="Store" />

        <.nav_item
          label="Promo Codes"
          path={~p"/admin/promotions"}
          active={String.starts_with?(@current_path, "/admin/promotions")}
          icon="badge"
          badge={Map.get(@counts, :promotions)}
          badge_variant={:count}
        />

        <.nav_item
          label="Customers"
          path={~p"/admin/customers"}
          active={String.starts_with?(@current_path, "/admin/customers")}
          icon="users"
          badge={Map.get(@counts, :customers)}
          badge_variant={:count}
        />

        <.nav_item
          label="Live Chat"
          path={~p"/admin/chat"}
          active={String.starts_with?(@current_path, "/admin/chat")}
          icon="message-circle"
          badge={Map.get(@counts, :open_chats)}
          badge_variant={:default}
        />

        <.nav_divider />
        <.nav_section label="System" />

        <.nav_item
          label="Team"
          path={~p"/admin/team"}
          active={String.starts_with?(@current_path, "/admin/team")}
          icon="users"
        />

        <.nav_item
          label="Info Pages"
          path={~p"/admin/pages"}
          active={String.starts_with?(@current_path, "/admin/pages")}
          icon="file-text"
        />

        <.nav_item
          label="Theme & Branding"
          path={~p"/admin/theme"}
          active={String.starts_with?(@current_path, "/admin/theme")}
          icon="palette"
        />

        <.nav_item
          label="Settings"
          path={~p"/admin/settings"}
          active={@current_path == "/admin/settings"}
          icon="settings"
        />

        <.nav_item
          label="Help & Reference"
          path={~p"/admin/help"}
          active={String.starts_with?(@current_path, "/admin/help")}
          icon="help"
        />
      </nav>

      <.sidebar_footer current_user={@current_user} />
    </aside>
    """
  end

  # ── Logo ──────────────────────────────────────────────────────────

  defp sidebar_logo(assigns) do
    ~H"""
    <div class="flex items-center gap-2.5 border-b border-gray-200 px-4 py-3.5">
      <img
        src="/images/sheglow-logo.png"
        alt="Sheglow"
        class="h-8 w-8 flex-shrink-0 rounded-full object-cover object-top ring-2 ring-[#C8001F]/60"
      />
      <div class="min-w-0">
        <span class="brand-logo block text-[17px] leading-tight text-gray-900">
          SheGlow UG<span class="text-[#C8001F]">.</span>
        </span>
        <span class="block text-[9px] uppercase tracking-widest text-gray-400">
          Fashion &amp; Function
        </span>
      </div>
      <span class="ml-auto flex-shrink-0 rounded-md bg-[#C8001F]/10 px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-[#C8001F]">
        Admin
      </span>
    </div>
    """
  end

  # ── Section Label ─────────────────────────────────────────────────

  defp nav_section(assigns) do
    ~H"""
    <p class="mb-1 mt-2 px-2 text-[10px] font-semibold uppercase tracking-widest text-gray-400">
      {@label}
    </p>
    """
  end

  # ── Divider ───────────────────────────────────────────────────────

  defp nav_divider(assigns) do
    ~H"""
    <div class="my-2 h-px bg-gray-100"></div>
    """
  end

  # ── Nav Item ──────────────────────────────────────────────────────

  @doc """
  A single sidebar nav link.

  ## Props
    - label       - display text
    - path        - href
    - active      - boolean
    - icon        - one of the icon keys below
    - badge       - integer or string, shown on right
    - badge_variant - :count | :alert (default :count)
  """
  defp nav_item(assigns) do
    assigns =
      assigns
      |> assign_new(:badge, fn -> nil end)
      |> assign_new(:badge_variant, fn -> :count end)
      |> assign_new(:active, fn -> false end)

    ~H"""
    <a
      href={@path}
      class={[
        "group flex items-center gap-2.5 rounded-xl px-2.5 py-2 text-[13px] font-medium transition-all",
        if(@active,
          do: "bg-[#C8001F] text-white shadow-sm shadow-[#C8001F]/30",
          else: "text-gray-600 hover:bg-[#C8001F]/8 hover:text-[#C8001F]"
        )
      ]}
    >
      <span class={if @active, do: "text-white", else: "text-gray-400 group-hover:text-[#C8001F]"}>
        <.nav_icon name={@icon} />
      </span>

      {@label}

      <%= if @badge && @badge > 0 do %>
        <span class={[
          "ml-auto rounded-full px-2 py-0.5 text-[10px] font-semibold tabular-nums",
          if(@active,
            do: "bg-white/20 text-white",
            else: "bg-[#C8001F]/10 text-[#C8001F]"
          )
        ]}>
          {@badge}
        </span>
      <% end %>
    </a>
    """
  end

  defp badge_class(:alert), do: "bg-red-100 text-red-600"
  defp badge_class(:count), do: "bg-gray-100 text-gray-500"
  defp badge_class(:default), do: "bg-gray-100 text-gray-600"
  defp badge_class(_), do: "bg-gray-100 text-gray-500"

  # ── Footer / User ─────────────────────────────────────────────────

  defp sidebar_footer(assigns) do
    assigns = assign_new(assigns, :current_user, fn -> nil end)

    ~H"""
    <div class="border-t border-gray-100 p-3 space-y-1">
      <!-- User row -->
      <a
        href={~p"/admin/team"}
        class="group flex items-center gap-2.5 rounded-xl px-2 py-2 transition hover:bg-gray-50"
      >
        <div class={"flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-xs font-bold text-white shadow-sm #{user_avatar_color(@current_user)}"}>
          {user_initials(@current_user)}
        </div>
        <div class="min-w-0 flex-1">
          <p class="truncate text-[13px] font-semibold text-gray-900">
            {user_display_name(@current_user)}
          </p>
          <p class="text-[11px] text-gray-400">{user_role_label(@current_user)}</p>
        </div>
        <svg
          class="h-3.5 w-3.5 flex-shrink-0 text-gray-300 group-hover:text-gray-500"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          stroke-width="2"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </a>
      
    <!-- Back to website -->
      <a
        href="/"
        class="group flex w-full items-center gap-2.5 rounded-xl px-2.5 py-2 text-[13px] font-medium text-gray-500 transition hover:bg-gray-100 hover:text-gray-900"
      >
        <svg
          class="h-4 w-4 text-gray-400 group-hover:text-gray-600"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
          />
        </svg>
        Back to Website
      </a>
      
    <!-- Logout -->
      <form action="/users/log_out" method="post">
        <input type="hidden" name="_method" value="delete" />
        <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
        <button
          type="submit"
          class="group flex w-full items-center gap-2.5 rounded-xl px-2.5 py-2 text-[13px] font-medium text-gray-500 transition hover:bg-red-50 hover:text-[#C8001F]"
        >
          <svg
            class="h-4 w-4 text-gray-400 group-hover:text-[#C8001F]"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
            />
          </svg>
          Log out
        </button>
      </form>
    </div>
    """
  end

  defp user_display_name(nil), do: "Admin"
  defp user_display_name(%{name: name}) when is_binary(name) and name != "", do: name
  defp user_display_name(%{email: email}), do: email |> String.split("@") |> List.first()

  defp user_role_label(nil), do: "Admin"
  defp user_role_label(%{role: "super_admin"}), do: "Super Admin"
  defp user_role_label(%{role: "admin"}), do: "Admin"
  defp user_role_label(_), do: "Member"

  defp user_initials(nil), do: "A"

  defp user_initials(%{name: name}) when is_binary(name) and name != "" do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp user_initials(%{email: email}) do
    email |> String.slice(0, 2) |> String.upcase()
  end

  defp user_avatar_color(nil), do: "bg-[#C8001F]"

  defp user_avatar_color(%{id: id}) do
    colors = [
      "bg-[#C8001F]",
      "bg-blue-500",
      "bg-violet-500",
      "bg-teal-500",
      "bg-amber-500",
      "bg-pink-500"
    ]

    Enum.at(colors, rem(id, length(colors)))
  end

  # ── Icons ─────────────────────────────────────────────────────────

  defp nav_icon(%{name: "grid"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <rect x="3" y="3" width="7" height="7" rx="1" />
      <rect x="14" y="3" width="7" height="7" rx="1" />
      <rect x="3" y="14" width="7" height="7" rx="1" />
      <rect x="14" y="14" width="7" height="7" rx="1" />
    </svg>
    """
  end

  defp nav_icon(%{name: "cart"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
    </svg>
    """
  end

  defp nav_icon(%{name: "chart"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
    </svg>
    """
  end

  defp nav_icon(%{name: "tag"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
      <line x1="7" y1="7" x2="7.01" y2="7" />
    </svg>
    """
  end

  defp nav_icon(%{name: "layers"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <polygon points="12 2 2 7 12 12 22 7 12 2" />
      <polyline points="2 17 12 22 22 17" />
      <polyline points="2 12 12 17 22 12" />
    </svg>
    """
  end

  defp nav_icon(%{name: "package"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <line x1="16.5" y1="9.4" x2="7.5" y2="4.21" />
      <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
      <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
      <line x1="12" y1="22.08" x2="12" y2="12" />
    </svg>
    """
  end

  defp nav_icon(%{name: "star"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
    </svg>
    """
  end

  defp nav_icon(%{name: "quote"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V20c0 1 0 1 1 1z" />
      <path d="M15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3c0 1 0 1 1 1z" />
    </svg>
    """
  end

  defp nav_icon(%{name: "badge"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="12" cy="8" r="6" />
      <path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11" />
    </svg>
    """
  end

  defp nav_icon(%{name: "users"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M23 21v-2a4 4 0 0 0-3-3.87m-4-12a4 4 0 0 1 0 7.75" />
    </svg>
    """
  end

  defp nav_icon(%{name: "monitor"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <rect x="2" y="3" width="20" height="14" rx="2" />
      <line x1="8" y1="21" x2="16" y2="21" />
      <line x1="12" y1="17" x2="12" y2="21" />
    </svg>
    """
  end

  defp nav_icon(%{name: "settings"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="12" cy="12" r="3" />
      <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
    </svg>
    """
  end

  defp nav_icon(%{name: "file-text"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
      />
    </svg>
    """
  end

  defp nav_icon(%{name: "help"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
    """
  end

  defp nav_icon(%{name: "palette"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M12 2C6.48 2 2 6.48 2 12c0 5.52 4.48 10 10 10 .83 0 1.5-.67 1.5-1.5 0-.39-.15-.74-.39-1.01-.23-.26-.38-.61-.38-.99 0-.83.67-1.5 1.5-1.5H16c2.76 0 5-2.24 5-5 0-4.42-4.03-8-9-8zm-5.5 9c-.83 0-1.5-.67-1.5-1.5S5.67 8 6.5 8 8 8.67 8 9.5 7.33 11 6.5 11zm3-4C8.67 7 8 6.33 8 5.5S8.67 4 9.5 4s1.5.67 1.5 1.5S10.33 7 9.5 7zm5 0c-.83 0-1.5-.67-1.5-1.5S13.67 4 14.5 4s1.5.67 1.5 1.5S15.33 7 14.5 7zm3 4c-.83 0-1.5-.67-1.5-1.5S16.67 8 17.5 8s1.5.67 1.5 1.5S18.33 11 17.5 11z"
      />
    </svg>
    """
  end

  defp nav_icon(%{name: "message-circle"} = assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
      />
    </svg>
    """
  end

  defp nav_icon(assigns) do
    ~H"""
    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="12" cy="12" r="10" />
    </svg>
    """
  end

  # ── Helpers ───────────────────────────────────────────────────────

  defp initials(nil), do: "A"

  defp initials(%{name: name}) when is_binary(name) do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp initials(_), do: "A"

  defp admin_name(nil), do: "Admin"
  defp admin_name(%{name: name}), do: name
  defp admin_name(_), do: "Admin"
end
