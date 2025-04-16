# config/config.exs

import Config

# -------------------------------------------------------------
# General Application Configuration
# -------------------------------------------------------------
config :ex_venture,
  namespace: Web,
  ecto_repos: [ExVenture.Repo]

config :ex_venture, :listener, start: true

# -------------------------------------------------------------
# Endpoint Configuration (Phoenix 1.7+)
# -------------------------------------------------------------
config :ex_venture, Web.Endpoint,
  render_errors: [
    formats: [html: Web.ErrorHTML, json: Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: ExVenture.PubSub,
  live_view: [signing_salt: "SECRET_SALT"] # Replace with real salt

# -------------------------------------------------------------
# Logger Configuration
# -------------------------------------------------------------
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# -------------------------------------------------------------
# JSON Parsing
# -------------------------------------------------------------
config :phoenix, :json_library, Jason

# -------------------------------------------------------------
# Optional: Porcelain Shell Execution (Legacy)
# -------------------------------------------------------------
config :porcelain, driver: Porcelain.Driver.Basic

# -------------------------------------------------------------
# Swoosh Mailer Configuration
# -------------------------------------------------------------
config :ex_venture, ExVenture.Mailer,
  adapter: Swoosh.Adapters.Local # Swap to SMTP, Postmark, etc. in prod

# Disable Swoosh API client unless using an API adapter
config :swoosh, :api_client, false

# -------------------------------------------------------------
# Tailwind Configuration
# -------------------------------------------------------------
# Configure tailwind version to avoid runtime warnings
config :tailwind, version: "3.3.3"


# -------------------------------------------------------------
# Import Environment Specific Config
# -------------------------------------------------------------
if File.exists?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
