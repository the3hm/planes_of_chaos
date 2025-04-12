# config/config.exs

import Config

# General application configuration
config :ex_venture,
  namespace: Web,
  ecto_repos: [ExVenture.Repo]

config :ex_venture, :listener, start: true

# Configures the endpoint
config :ex_venture, Web.Endpoint,
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)],
  pubsub_server: ExVenture.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Optional: Porcelain config if you're using it
config :porcelain, driver: Porcelain.Driver.Basic

# ✅ Swoosh Mailer Configuration (Local for Dev)
config :ex_venture, ExVenture.Mailer, adapter: Swoosh.Adapters.Local

# ✅ Disable Swoosh API client if not using one
config :swoosh, :api_client, false

# Import environment specific config (e.g., dev.exs, prod.exs)
if File.exists?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
