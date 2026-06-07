defmodule SheglowWeb.UserResetPasswordLive do
  use SheglowWeb, :live_view

  alias Sheglow.Accounts

  def render(assigns) do
    ~H"""
    <div id="auth-page" class="page-typography min-h-screen flex flex-col bg-white">
      <.promo_bar />
      <.navbar collections={[]} />

      <main class="flex-1">
        <section class="bg-[#f5f5f3] px-4 py-16 sm:px-6 sm:py-24 lg:px-8">
          <div class="mx-auto max-w-md">
            <div class="rounded-lg border border-gray-200 bg-white px-6 py-10 shadow-sm sm:px-12 sm:py-14">
              <header class="text-center">
                <h1 class="font-instrument-bold text-2xl text-gray-900 sm:text-3xl">
                  Reset Password
                </h1>
              </header>

              <.simple_form
                for={@form}
                id="reset_password_form"
                phx-submit="reset_password"
                phx-change="validate"
                class="mt-10"
              >
                <.error :if={@form.errors != []}>
                  Oops, something went wrong! Please check the errors below.
                </.error>

                <.input field={@form[:password]} type="password" label="New password" required />
                <.input
                  field={@form[:password_confirmation]}
                  type="password"
                  label="Confirm new password"
                  required
                />
                <:actions>
                  <.button phx-disable-with="Resetting..." class="w-full">Reset Password</.button>
                </:actions>
              </.simple_form>

              <p class="mt-6 text-center text-sm text-gray-600">
                <.link href={~p"/users/register"} class="font-medium text-gray-900 hover:text-gray-600">Register</.link>
                <span class="mx-2">·</span>
                <.link href={~p"/users/log_in"} class="font-medium text-gray-900 hover:text-gray-600">Log in</.link>
              </p>
            </div>
          </div>
        </section>
      </main>

      <.footer />
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
