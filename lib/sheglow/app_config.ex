defmodule Sheglow.AppConfig do
  @moduledoc """
  Runtime application configuration helpers.

  Values are read from the application environment at call time so they
  reflect whatever is set in config/runtime.exs or overridden by env vars.
  """

  @doc """
  Returns the public site URL (no trailing slash).

  Configurable via:
    - `config :sheglow, site_url: \"https://kulolascloset.com\"` in config files
    - `SITE_URL` environment variable at runtime (prod)
  """
  def site_url do
    Application.get_env(:sheglow, :site_url, "https://kulolascloset.com")
    |> String.trim_trailing("/")
  end

  @doc """
  Returns the admin email address for order notifications.

  Configurable via:
    - `config :sheglow, admin_email: \"...\"` in config files
    - `ADMIN_EMAIL` environment variable at runtime (prod)
  """
  def admin_email do
    Application.get_env(:sheglow, :admin_email, "kulolacloset@gmail.com")
  end
end
