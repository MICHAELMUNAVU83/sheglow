defmodule Sheglow.Repo do
  use Ecto.Repo,
    otp_app: :sheglow,
    adapter: Ecto.Adapters.Postgres
end
