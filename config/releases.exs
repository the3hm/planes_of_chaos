import Config

config :ex_venture, ExVenture.Repo, ssl: System.get_env("DATABASE_SSL") == "true"

config :ex_venture, Web.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :ex_venture, ExVenture.Mailer, adapter: Swoosh.Adapters.SMTP

config :logger, level: :info

config :phoenix, :logger, false

config :stein_phoenix, :views, error_helpers: Web.ErrorHelpers
