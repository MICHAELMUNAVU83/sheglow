defmodule SheglowWeb.TeamLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Accounts
  alias Sheglow.Accounts.{User, UserNotifier}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Team")
     |> assign(:current_path, "/admin/team")
     |> assign(:users, Accounts.list_users())
     |> assign(:show_invite, false)
     |> assign(:editing_id, nil)
     |> assign(:invite_form, blank_invite_form())
     |> assign(:edit_form, nil)
     |> assign(:form_error, nil)}
  end

  # ── Events ────────────────────────────────────────────────────────────────

  @impl true
  def handle_event("show_invite", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_invite, true)
     |> assign(:editing_id, nil)
     |> assign(:edit_form, nil)
     |> assign(:invite_form, blank_invite_form())}
  end

  def handle_event("hide_invite", _params, socket) do
    {:noreply, socket |> assign(:show_invite, false) |> assign(:form_error, nil)}
  end

  def handle_event("validate_invite", %{"user" => params}, socket) do
    changeset = Accounts.change_invite(%User{}, params) |> Map.put(:action, :validate)
    {:noreply, assign(socket, :invite_form, to_form(changeset, as: "user"))}
  end

  def handle_event("send_invite", %{"user" => params}, socket) do
    case Accounts.invite_user(params) do
      {:ok, user} ->
        temp_password = params["password"]
        Task.start(fn -> UserNotifier.deliver_welcome_with_credentials(user, temp_password) end)

        {:noreply,
         socket
         |> assign(:users, Accounts.list_users())
         |> assign(:show_invite, false)
         |> assign(:invite_form, blank_invite_form())
         |> assign(:form_error, nil)
         |> put_flash(:info, "Team member added and welcome email sent to #{user.email}.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:invite_form, to_form(changeset, as: "user"))
         |> assign(:form_error, "Please fix the errors below.")}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_admin_user(user)

    {:noreply,
     socket
     |> assign(:editing_id, user.id)
     |> assign(:edit_form, to_form(changeset, as: "user"))
     |> assign(:show_invite, false)
     |> assign(:form_error, nil)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, socket |> assign(:editing_id, nil) |> assign(:edit_form, nil) |> assign(:form_error, nil)}
  end

  def handle_event("validate_edit", %{"user" => params}, socket) do
    user = Accounts.get_user!(socket.assigns.editing_id)
    changeset = Accounts.change_admin_user(user, params) |> Map.put(:action, :validate)
    {:noreply, assign(socket, :edit_form, to_form(changeset, as: "user"))}
  end

  def handle_event("save_edit", %{"user" => params}, socket) do
    user = Accounts.get_user!(socket.assigns.editing_id)

    case Accounts.admin_update_user(user, params) do
      {:ok, _updated} ->
        {:noreply,
         socket
         |> assign(:users, Accounts.list_users())
         |> assign(:editing_id, nil)
         |> assign(:edit_form, nil)
         |> assign(:form_error, nil)
         |> put_flash(:info, "Member updated.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:edit_form, to_form(changeset, as: "user"))
         |> assign(:form_error, "Please fix the errors below.")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    current = socket.assigns.current_user

    if to_string(current.id) == id do
      {:noreply, put_flash(socket, :error, "You cannot delete your own account.")}
    else
      user = Accounts.get_user!(id)
      {:ok, _} = Accounts.delete_user(user)

      {:noreply,
       socket
       |> assign(:users, Accounts.list_users())
       |> put_flash(:info, "Member removed.")}
    end
  end

  # ── Helpers ────────────────────────────────────────────────────────────────

  defp blank_invite_form do
    to_form(Accounts.change_invite(%User{}), as: "user")
  end

  defp role_label("super_admin"), do: "Super Admin"
  defp role_label("admin"), do: "Admin"
  defp role_label("member"), do: "Member"
  defp role_label(_), do: "Member"

  defp role_badge("super_admin"), do: "bg-[#C8001F]/10 text-[#C8001F]"
  defp role_badge("admin"), do: "bg-blue-100 text-blue-700"
  defp role_badge(_), do: "bg-gray-100 text-gray-600"

  defp initials(nil), do: "?"
  defp initials(email) do
    email |> String.split("@") |> List.first() |> String.slice(0, 2) |> String.upcase()
  end

  defp avatar_color(id) do
    colors = ~w[bg-red-400 bg-orange-400 bg-amber-400 bg-green-500 bg-teal-500 bg-blue-500 bg-violet-500 bg-pink-500]
    Enum.at(colors, rem(id, length(colors)))
  end

  defp format_dt(nil), do: "Never"
  defp format_dt(%DateTime{} = dt) do
    Calendar.strftime(dt, "%b %d, %Y · %H:%M")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- Header --%>
      <div class="mb-8 flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Team Members</h1>
          <p class="mt-1 text-sm text-gray-500">
            {@users |> length()} members · Admin access only
          </p>
        </div>
        <button
          type="button"
          phx-click="show_invite"
          class="flex items-center gap-2 rounded-xl bg-[#C8001F] px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-[var(--brand-primary-dark)]"
        >
          <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Add Member
        </button>
      </div>

      <%!-- Invite form --%>
      <%= if @show_invite do %>
        <div class="mb-8 overflow-hidden rounded-3xl border border-[#C8001F]/20 bg-white shadow-sm">
          <div class="flex items-center justify-between border-b border-gray-100 px-6 py-4">
            <h2 class="text-sm font-semibold text-gray-900">Add New Team Member</h2>
            <button type="button" phx-click="hide_invite" class="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 transition">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <.form
            for={@invite_form}
            phx-change="validate_invite"
            phx-submit="send_invite"
            class="grid gap-5 p-6 sm:grid-cols-2 lg:grid-cols-4"
          >
            <%= if @form_error do %>
              <p class="col-span-full rounded-xl bg-red-50 px-4 py-3 text-sm text-red-600">{@form_error}</p>
            <% end %>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                Full Name <span class="text-red-500">*</span>
              </label>
              <.input field={@invite_form[:name]} type="text" placeholder="Jane Doe" />
            </div>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                Email <span class="text-red-500">*</span>
              </label>
              <.input field={@invite_form[:email]} type="email" placeholder="jane@example.com" />
            </div>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                Temporary Password <span class="text-red-500">*</span>
              </label>
              <.input field={@invite_form[:password]} type="password" placeholder="Min. 6 characters" />
            </div>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Role</label>
              <.input
                field={@invite_form[:role]}
                type="select"
                options={[{"Member", "member"}, {"Admin", "admin"}, {"Super Admin", "super_admin"}]}
              />
            </div>
            <div class="col-span-full flex items-center gap-3 pt-1">
              <button
                type="submit"
                class="rounded-xl bg-[#C8001F] px-6 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-[var(--brand-primary-dark)]"
              >
                Add Member
              </button>
              <button
                type="button"
                phx-click="hide_invite"
                class="rounded-xl border border-gray-300 px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50"
              >
                Cancel
              </button>
              <p class="ml-2 text-xs text-gray-400">
                Share the email + password with the member so they can log in.
              </p>
            </div>
          </.form>
        </div>
      <% end %>

      <%!-- Team table --%>
      <div class="overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm">
        <%= if @users == [] do %>
          <div class="px-6 py-16 text-center">
            <p class="text-4xl">👥</p>
            <p class="mt-3 text-sm font-medium text-gray-500">No team members yet.</p>
          </div>
        <% else %>
          <div class="divide-y divide-gray-100">
            <%= for user <- @users do %>
              <div class="px-6 py-5">
                <%!-- Normal row --%>
                <div class="flex items-center gap-4">
                  <%!-- Avatar --%>
                  <div class={"flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold text-white #{avatar_color(user.id)}"}>
                    {initials(user.email)}
                  </div>

                  <%!-- Info --%>
                  <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-center gap-2">
                      <span class="text-sm font-semibold text-gray-900">
                        {user.name || user.email}
                      </span>
                      <span class={"rounded-full px-2 py-0.5 text-[11px] font-medium #{role_badge(user.role)}"}>
                        {role_label(user.role)}
                      </span>
                      <%= if user.id == @current_user.id do %>
                        <span class="rounded-full bg-green-100 px-2 py-0.5 text-[11px] font-medium text-green-700">You</span>
                      <% end %>
                    </div>
                    <p class="mt-0.5 text-xs text-gray-400">{user.email}</p>
                  </div>

                  <%!-- Last signed in --%>
                  <div class="hidden text-right sm:block">
                    <p class="text-[11px] font-medium text-gray-400 uppercase tracking-wide">Last sign-in</p>
                    <p class="mt-0.5 text-xs text-gray-600">{format_dt(user.last_signed_in_at)}</p>
                  </div>

                  <%!-- Member since --%>
                  <div class="hidden text-right lg:block">
                    <p class="text-[11px] font-medium text-gray-400 uppercase tracking-wide">Member since</p>
                    <p class="mt-0.5 text-xs text-gray-600">
                      {Calendar.strftime(user.inserted_at, "%b %d, %Y")}
                    </p>
                  </div>

                  <%!-- Actions --%>
                  <div class="flex flex-shrink-0 items-center gap-2">
                    <button
                      type="button"
                      phx-click="edit"
                      phx-value-id={user.id}
                      class="rounded-lg border border-gray-200 px-3 py-1.5 text-xs font-medium text-gray-600 transition hover:border-[#C8001F]/40 hover:text-[#C8001F]"
                    >
                      Edit
                    </button>
                    <%= if user.id != @current_user.id do %>
                      <button
                        type="button"
                        phx-click="delete"
                        phx-value-id={user.id}
                        data-confirm={"Remove #{user.name || user.email} from the team?"}
                        class="rounded-lg border border-red-100 px-3 py-1.5 text-xs font-medium text-red-500 transition hover:bg-red-50"
                      >
                        Remove
                      </button>
                    <% end %>
                  </div>
                </div>

                <%!-- Edit form (inline below the row) --%>
                <%= if @editing_id == user.id do %>
                  <.form
                    for={@edit_form}
                    phx-change="validate_edit"
                    phx-submit="save_edit"
                    class="mt-4 grid gap-4 rounded-2xl border border-gray-100 bg-gray-50 p-5 sm:grid-cols-3"
                  >
                    <%= if @form_error do %>
                      <p class="col-span-full rounded-xl bg-red-50 px-3 py-2 text-sm text-red-600">{@form_error}</p>
                    <% end %>
                    <div>
                      <label class="mb-1 block text-xs font-semibold text-gray-600">Full Name</label>
                      <.input field={@edit_form[:name]} type="text" placeholder="Full name" />
                    </div>
                    <div>
                      <label class="mb-1 block text-xs font-semibold text-gray-600">Role</label>
                      <.input
                        field={@edit_form[:role]}
                        type="select"
                        options={[{"Member", "member"}, {"Admin", "admin"}, {"Super Admin", "super_admin"}]}
                      />
                    </div>
                    <div class="flex items-end gap-2">
                      <button
                        type="submit"
                        class="rounded-xl bg-[#C8001F] px-4 py-2 text-xs font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
                      >
                        Save
                      </button>
                      <button
                        type="button"
                        phx-click="cancel_edit"
                        class="rounded-xl border border-gray-300 px-4 py-2 text-xs font-medium text-gray-600 transition hover:bg-white"
                      >
                        Cancel
                      </button>
                    </div>
                  </.form>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
