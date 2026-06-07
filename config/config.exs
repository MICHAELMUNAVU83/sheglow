# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :sheglow,
  ecto_repos: [Sheglow.Repo],
  generators: [timestamp_type: :utc_datetime],
  # Public-facing site URL used in emails and links.
  # Override with the SITE_URL env var in production (see config/runtime.exs).
  site_url: "https://kulolascloset.com",
  # Admin email that receives new-order notifications.
  # Must be a real deliverable address. Override with ADMIN_EMAIL env var.
  admin_email: "kulolacloset@gmail.com"

# Configures the endpoint
config :sheglow, SheglowWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SheglowWeb.ErrorHTML, json: SheglowWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Sheglow.PubSub,
  live_view: [signing_salt: "8vDawJSP"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :sheglow, Sheglow.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  sheglow: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  sheglow: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
