defmodule SheglowWeb.HelpLive.Index do
  use SheglowWeb, :admin_live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Admin Help & Reference")
     |> assign(:current_path, "/admin/help")
     |> assign(:active_section, "dashboard")}
  end

  @impl true
  def handle_event("set_section", %{"section" => section}, socket) do
    {:noreply, assign(socket, :active_section, section)}
  end

  @sections [
    %{
      id: "dashboard",
      label: "Dashboard",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
      """,
      title: "Dashboard",
      path: "/admin",
      summary: "Your command centre — get a live snapshot of the store at a glance.",
      items: [
        {"Revenue & Orders",
         "Today's revenue, total orders, and pending fulfilment count update in real time."},
        {"Quick Stats", "Counts for products, collections, customers, and active promo codes."},
        {"Recent Orders",
         "The 5 most recent orders with status badges. Click any row to open the full order detail."},
        {"Top Products", "Best-selling products ranked by units sold this month."}
      ]
    },
    %{
      id: "orders",
      label: "Orders",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
      """,
      title: "Orders",
      path: "/admin/orders",
      summary: "View and manage every customer order placed through the store.",
      items: [
        {"Order List",
         "All orders sorted newest-first. Filter by status (pending / paid / fulfilled / cancelled). Each row shows the reference, customer name, total, and date."},
        {"Order Detail",
         "Click an order to see full item breakdown, delivery address, payment reference, and a timeline of status changes."},
        {"Status Updates",
         "Use the status dropdown on the detail page to mark an order as fulfilled or cancelled. The customer receives an email on each change."},
        {"Search",
         "Filter orders by reference number or customer email using the search bar at the top."}
      ]
    },
    %{
      id: "products",
      label: "Products",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
      """,
      title: "Products",
      path: "/admin/products",
      summary: "Create and maintain the full product catalogue.",
      items: [
        {"Product List",
         "Grid view of all products with name, price, collection, and stock status. Use the search bar or collection filter to narrow results."},
        {"New Product",
         "Click 'New Product' to open the creation form. Required fields: name, slug (auto-generated from name), price, and at least one image."},
        {"Product Detail",
         "Click a product name to open its detail page where you can edit description, size advice, shipping & returns text, SEO meta tags, and manage its images."},
        {"Variants",
         "Each product can have multiple colour/size variants managed from the product detail page under the Variants tab. Set stock count per variant."},
        {"Images",
         "Upload images from the product detail page. The first image is used as the listing thumbnail. Drag to reorder."},
        {"Collections",
         "Assign a product to one or more collections using the collection selector on the edit form."}
      ]
    },
    %{
      id: "collections",
      label: "Collections",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
      """,
      title: "Collections",
      path: "/admin/collections",
      summary: "Group products into themed collections displayed on the storefront.",
      items: [
        {"Collection List",
         "All collections with product count and active/inactive status. Collections marked inactive are hidden from the public store."},
        {"Create Collection",
         "Provide a name, slug, description, and cover image. The slug becomes the public URL path (e.g. /collections/summer-edit)."},
        {"Edit Collection",
         "Update name, description, cover image, and toggle visibility at any time."},
        {"Homepage Display",
         "Active collections appear in the collections grid and can be randomly selected for the hero banner and countdown section on each page load."}
      ]
    },
    %{
      id: "bundles",
      label: "Bundles",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 4a2 2 0 100 4m0-4a2 2 0 110 4m6-4a2 2 0 100 4m0-4a2 2 0 110 4"/>
      """,
      title: "Bundles",
      path: "/admin/bundles",
      summary: "Create 'Bundle & Save' deals that group multiple products at a discounted price.",
      items: [
        {"Bundle List",
         "All bundles with name, price, and active status. Only one bundle can be active (displayed on the homepage) at a time."},
        {"Create Bundle",
         "Set a name, bundle price, and description. Then add items by linking existing products."},
        {"Bundle Items",
         "Manage the individual products included in a bundle from the bundle detail page. Minimum 2 items are recommended for display."},
        {"Activate", "Toggle a bundle active to show it in the 'Bundle & Save' homepage section."}
      ]
    },
    %{
      id: "promotions",
      label: "Promo Codes",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
      """,
      title: "Promo Codes",
      path: "/admin/promotions",
      summary: "Create and manage discount codes customers can apply at checkout.",
      items: [
        {"Code List",
         "All promo codes with type (percentage / fixed), discount value, usage count, and expiry date."},
        {"Create Code",
         "Enter the code text, choose discount type, set the value (e.g. 10 for 10% off or 5,000 for UGX 5,000 off), optional minimum order amount, and expiry date."},
        {"Usage Tracking",
         "Each time a code is redeemed the usage counter increments. You can see which orders used a specific code from the order list."},
        {"Deactivate",
         "Toggle a code inactive to prevent further redemptions without deleting it."}
      ]
    },
    %{
      id: "customers",
      label: "Customers",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
      """,
      title: "Customers",
      path: "/admin/customers",
      summary: "Browse customers who have placed orders through the store.",
      items: [
        {"Customer List",
         "All unique customers derived from placed orders, with email, phone, and order count."},
        {"Customer Detail",
         "Click a customer to see their full order history, total spend, and delivery addresses."},
        {"Search", "Filter by name or email using the search bar."},
        {"Note",
         "Customer accounts are not required for checkout — customers are tracked by their email at order time."}
      ]
    },
    %{
      id: "team",
      label: "Team",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
      """,
      title: "Team",
      path: "/admin/team",
      summary: "Manage the people who have access to this admin panel.",
      items: [
        {"Member List",
         "All admin accounts with their name, email, role, and last sign-in time."},
        {"Invite Member",
         "Click 'Add Member', enter their name, email, a temporary password, and assign a role. They will receive a welcome email with login instructions."},
        {"Roles",
         "super_admin — full access including team management. admin — can manage catalogue, orders, and content. member — read-only access."},
        {"Edit / Remove",
         "Update a member's name or role inline. Use the delete button to revoke access (you cannot delete yourself)."}
      ]
    },
    %{
      id: "pages",
      label: "Info Pages",
      icon: """
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
        d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
      """,
      title: "Info Pages",
      path: "/admin/pages",
      summary:
        "Edit the public-facing informational pages like How to Order, Size Guide, and Returns.",
      items: [
        {"Page List", "All info pages with their slug, title, and active/inactive status."},
        {"Edit Content",
         "Click the edit icon on any page to update its title, meta description, and body content. Content supports plain text with line breaks."},
        {"Activate / Deactivate",
         "Toggle a page's active status. Inactive pages are hidden from the public /info/:slug route and from the storefront footer links."},
        {"Public URL",
         "Each page is accessible at /info/:slug (e.g. /info/how-to-order). Links appear automatically in the storefront footer under Customer Care."}
      ]
    }
  ]

  @impl true
  def render(assigns) do
    sections = @sections
    assigns = assign(assigns, :sections, sections)

    ~H"""
    <div class="flex h-full min-h-screen flex-col">
      <%!-- Header --%>
      <div class="border-b border-gray-100 bg-white px-6 py-5">
        <div class="flex items-center gap-3">
          <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-[#C8001F]/10">
            <svg class="h-5 w-5 text-[#C8001F]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="1.5"
                d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <div>
            <h1 class="text-lg font-semibold text-gray-900">Admin Help & Reference</h1>
            <p class="text-sm text-gray-500">A guide to every section of the admin panel</p>
          </div>
        </div>
      </div>

      <div class="flex flex-1 overflow-hidden">
        <%!-- Section nav --%>
        <nav class="hidden w-56 shrink-0 border-r border-gray-100 bg-gray-50/50 py-4 lg:block">
          <p class="px-4 pb-2 text-[10px] font-semibold uppercase tracking-widest text-gray-400">
            Sections
          </p>
          <%= for section <- @sections do %>
            <button
              phx-click="set_section"
              phx-value-section={section.id}
              class={[
                "flex w-full items-center gap-2.5 px-4 py-2.5 text-left text-sm font-medium transition",
                if(@active_section == section.id,
                  do: "bg-white text-[#C8001F] shadow-sm border-r-2 border-[#C8001F]",
                  else: "text-gray-600 hover:bg-white hover:text-gray-900"
                )
              ]}
            >
              <svg class="h-4 w-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                {Phoenix.HTML.raw(section.icon)}
              </svg>
              {section.label}
            </button>
          <% end %>
        </nav>

        <%!-- Main content --%>
        <div class="flex-1 overflow-y-auto p-6 lg:p-8">
          <%!-- Mobile section picker --%>
          <div class="mb-6 lg:hidden">
            <label class="mb-1 block text-xs font-semibold uppercase tracking-wider text-gray-500">
              Jump to section
            </label>
            <div class="flex flex-wrap gap-2">
              <%= for section <- @sections do %>
                <button
                  phx-click="set_section"
                  phx-value-section={section.id}
                  class={[
                    "rounded-full border px-3 py-1 text-xs font-medium transition",
                    if(@active_section == section.id,
                      do: "border-[#C8001F] bg-[#C8001F] text-white",
                      else: "border-gray-200 text-gray-600 hover:border-gray-400"
                    )
                  ]}
                >
                  {section.label}
                </button>
              <% end %>
            </div>
          </div>

          <%!-- Active section card --%>
          <%= for section <- @sections, section.id == @active_section do %>
            <div class="max-w-2xl">
              <%!-- Section header --%>
              <div class="mb-6 flex items-start gap-4">
                <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-[#C8001F]/10">
                  <svg
                    class="h-6 w-6 text-[#C8001F]"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    {Phoenix.HTML.raw(section.icon)}
                  </svg>
                </div>
                <div>
                  <h2 class="text-2xl font-bold text-gray-900">{section.title}</h2>
                  <p class="mt-1 text-sm text-gray-500">{section.summary}</p>
                  <a
                    href={section.path}
                    class="mt-2 inline-flex items-center gap-1 text-xs font-medium text-[#C8001F] hover:underline"
                  >
                    Go to {section.title}
                    <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9 5l7 7-7 7"
                      />
                    </svg>
                  </a>
                </div>
              </div>

              <%!-- Items --%>
              <div class="space-y-3">
                <%= for {term, desc} <- section.items do %>
                  <div class="rounded-xl border border-gray-100 bg-white p-4 shadow-sm">
                    <p class="mb-1 text-sm font-semibold text-gray-900">{term}</p>
                    <p class="text-sm leading-relaxed text-gray-600">{desc}</p>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
