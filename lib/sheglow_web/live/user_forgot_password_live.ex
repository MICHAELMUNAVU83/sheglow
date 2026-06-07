defmodule SheglowWeb.UserForgotPasswordLive do
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
                  Forgot your password?
                </h1>
                <p class="mt-2 text-sm leading-6 text-gray-600">
                  We'll send a password reset link to your inbox
                </p>
              </header>

              <.simple_form for={@form} id="reset_password_form" phx-submit="send_email" class="mt-10">
                <.input field={@form[:email]} type="email" label="Email" required />
                <:actions>
                  <.button phx-disable-with="Sending..." class="w-full">
                    Send password reset instructions
                  </.button>
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &(Sheglow.AppConfig.site_url() <> ~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
