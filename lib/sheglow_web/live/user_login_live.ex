defmodule SheglowWeb.UserLoginLive do
  use SheglowWeb, :live_view

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
                  Log in to account
                </h1>
                <p class="mt-2 text-sm leading-6 text-gray-600">
                  Admin access only. Contact the team owner to get an account.
                </p>
              </header>

              <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore" class="mt-10">
                <.input field={@form[:email]} type="email" label="Email" required />
                <.input field={@form[:password]} type="password" label="Password" required />

                <:actions>
                  <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
                    <.link href={~p"/users/reset_password"} class="text-sm font-medium text-gray-900 hover:text-gray-600">
                      Forgot your password?
                    </.link>
                  </div>
                </:actions>
                <:actions>
                  <.button phx-disable-with="Logging in..." class="w-full">
                    Log in <span aria-hidden="true">→</span>
                  </.button>
                </:actions>
              </.simple_form>
            </div>
          </div>
        </section>
      </main>

      <.footer />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
