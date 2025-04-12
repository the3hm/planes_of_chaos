import Config

#
# If you're looking to update variables, you probably want to:
# - Edit `.env.test`
# - Add to `ExVenture.Config` for loading through Vapor
#

# Configure your database for test
config :ex_venture, ExVenture.Repo,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test
config :ex_venture, Web.Endpoint,
  http: [port: 4002],
  server: false

# Use test adapter for mailer
config :ex_venture, ExVenture.Mailer,
  adapter: Swoosh.Adapters.Test

# Disable listener startup
config :ex_venture, :listener, start: false

# Show only warnings and errors in test logs
config :logger, level: :warn

# Lower bcrypt complexity for fast tests
config :bcrypt_elixir, :log_rounds, 4

# Use test storage backend
config :stein_storage,
  backend: :test
