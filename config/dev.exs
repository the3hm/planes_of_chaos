import Config

# -------------------------------------------------------------------
# Database Configuration
# -------------------------------------------------------------------

config :ex_venture, ExVenture.Repo,
  show_sensitive_data_on_connection_error: true

# -------------------------------------------------------------------
# Endpoint Configuration
# -------------------------------------------------------------------

config :ex_venture, Web.Endpoint,
  server: true,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    js: {
      :node,
      ["./assets/yarn.sh", "run", "build:js:watch"],
      cd: Path.expand("../assets", __DIR__)
    },
    css: {
      :node,
      ["./assets/yarn.sh", "run", "build:css:watch"],
      cd: Path.expand("../assets", __DIR__)
    },
    static: {
      :node,
      ["./assets/yarn.sh", "run", "build:static:watch"],
      cd: Path.expand("../assets", __DIR__)
    }
  ]


# -------------------------------------------------------------------
# Mailer (Swoosh)
# -------------------------------------------------------------------

config :ex_venture, ExVenture.Mailer,
  adapter: Swoosh.Adapters.SMTP

# -------------------------------------------------------------------
# Logger
# -------------------------------------------------------------------

config :logger, :console,
  format: "[$level] $message\n"

# -------------------------------------------------------------------
# Phoenix Development Options
# -------------------------------------------------------------------

config :phoenix,
  stacktrace_depth: 20,
  plug_init_mode: :runtime,
  logger: false

# -------------------------------------------------------------------
# Local Uploads
# -------------------------------------------------------------------

config :stein_storage,
  backend: :file,
  file_backend_folder: "uploads/"
