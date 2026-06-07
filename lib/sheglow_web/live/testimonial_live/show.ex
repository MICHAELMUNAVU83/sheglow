defmodule SheglowWeb.TestimonialLive.Show do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Testimonials

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Testimonial")
     |> assign(:current_path, "/admin/testimonials")}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    testimonial = Testimonials.get_testimonial!(id)

    {:noreply,
     socket
     |> assign(:page_title, testimonial.name)
     |> assign(:testimonial, testimonial)}
  end

  @impl true
  def handle_info({SheglowWeb.TestimonialLive.FormComponent, {:saved, testimonial}}, socket) do
    {:noreply, assign(socket, :testimonial, testimonial)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Page header --%>
    <div class="mb-8 flex items-center justify-between">
      <div class="flex items-center gap-4">
        <.link navigate={~p"/admin/testimonials"}>
          <button class="flex h-10 w-10 items-center justify-center rounded-xl border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700">
            <svg
              class="h-5 w-5"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
        </.link>
        <div>
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Testimonials</p>
          <h1 class="mt-0.5 text-2xl font-bold text-gray-900">{@testimonial.name}</h1>
        </div>
      </div>

      <.link patch={~p"/admin/testimonials/#{@testimonial}/show/edit"}>
        <button class="flex items-center gap-2 rounded-xl bg-gray-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-gray-700">
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
          </svg>
          Edit
        </button>
      </.link>
    </div>

    <%!-- Testimonial card --%>
    <div class="mx-auto max-w-2xl">
      <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white">
        <%!-- Status bar --%>
        <div class="flex items-center justify-between border-b border-gray-100 px-6 py-4">
          <span class={[
            "inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-semibold",
            if(@testimonial.is_active,
              do: "bg-green-50 text-green-700",
              else: "bg-gray-100 text-gray-500"
            )
          ]}>
            <span class={[
              "h-1.5 w-1.5 rounded-full",
              if(@testimonial.is_active, do: "bg-green-500", else: "bg-gray-400")
            ]} />
            {if @testimonial.is_active, do: "Active", else: "Inactive"}
          </span>
          <span class="text-xs text-gray-400">Position {@testimonial.position}</span>
        </div>

        <%!-- Body --%>
        <div class="px-8 py-8">
          <%!-- Quote mark --%>
          <svg class="mb-4 h-8 w-8 text-gray-200" viewBox="0 0 24 24" fill="currentColor">
            <path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V20c0 1 0 1 1 1z" />
            <path d="M15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3c0 1 0 1 1 1z" />
          </svg>

          <p class="text-lg leading-relaxed text-gray-700">"{@testimonial.body}"</p>

          <%!-- Stars --%>
          <div class="mt-5 flex items-center gap-1">
            <%= for i <- 1..5 do %>
              <svg
                class={[
                  "h-5 w-5",
                  if(i <= (@testimonial.rating || 0), do: "text-amber-400", else: "text-gray-200")
                ]}
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
              </svg>
            <% end %>
            <span class="ml-1.5 text-sm font-semibold text-gray-700">{@testimonial.rating}/5</span>
          </div>
        </div>

        <%!-- Author --%>
        <div class="flex items-center gap-4 border-t border-gray-100 px-8 py-5">
          <%= if @testimonial.image && @testimonial.image != "" do %>
            <img
              src={@testimonial.image}
              alt={@testimonial.name}
              class="h-14 w-14 rounded-full border border-gray-200 object-cover object-top shadow-sm"
            />
          <% else %>
            <div class="flex h-14 w-14 items-center justify-center rounded-full bg-gray-100 text-xl font-bold text-gray-400">
              {String.first(@testimonial.name || "?")}
            </div>
          <% end %>
          <div>
            <p class="text-base font-semibold text-gray-900">{@testimonial.name}</p>
            <p class="text-sm text-gray-400">Verified Customer</p>
          </div>
        </div>

        <%!-- Linked product --%>
        <%= if @testimonial.product do %>
          <div class="border-t border-gray-100 px-8 py-5">
            <p class="mb-3 text-xs font-semibold uppercase tracking-widest text-gray-400">
              Linked Product
            </p>
            <.link
              navigate={~p"/admin/products/#{@testimonial.product}"}
              class="flex items-center gap-4 rounded-xl border border-gray-200 bg-gray-50 p-4 transition hover:bg-gray-100"
            >
              <%= if @testimonial.product.image && @testimonial.product.image != "" do %>
                <img
                  src={@testimonial.product.image}
                  alt={@testimonial.product.name}
                  class="h-14 w-14 flex-shrink-0 rounded-xl border border-gray-200 object-cover"
                />
              <% else %>
                <div class="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-xl bg-gray-200 text-2xl">
                  👗
                </div>
              <% end %>
              <div class="min-w-0 flex-1">
                <p class="font-semibold text-gray-900">{@testimonial.product.name}</p>
                <p class="text-sm text-gray-400">{@testimonial.product.slug}</p>
              </div>
              <span class="text-sm font-semibold text-gray-700">
                Ksh {@testimonial.product.base_price}
              </span>
              <svg
                class="h-4 w-4 flex-shrink-0 text-gray-400"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M9 18l6-6-6-6" />
              </svg>
            </.link>
          </div>
        <% end %>
      </div>
    </div>

    <%!-- Edit modal --%>
    <.modal
      :if={@live_action == :edit}
      id="testimonial-modal"
      show
      on_cancel={JS.patch(~p"/admin/testimonials/#{@testimonial}")}
    >
      <.live_component
        module={SheglowWeb.TestimonialLive.FormComponent}
        id={@testimonial.id}
        title="Edit Testimonial"
        action={@live_action}
        testimonial={@testimonial}
        patch={~p"/admin/testimonials/#{@testimonial}"}
      />
    </.modal>
    """
  end
end
