import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/ex_venture start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :ex_venture, Web.Endpoint, server: true
end

# ## Configuring the endpoint server for releases
#
# # By default, Phoenix releases start you server listening
# # on port 4000 and accepts only local connections.
# # You should change your configuration to listen on a different port
# # and accept connections from the outside world, at least
# # if you plan to deploy it.
# config :ex_venture, Web.Endpoint,
#   http: [ip: {0, 0, 0, 0}, port: 4000],
#   secret_key_base: secret_key_base

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:keyfile` and `:certfile`.
#
# By default, Phoenix expects the keyfile and certfile to be
# stored in the `priv/cert` folder.
#
# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to start
# by passing a list of endpoints to `:serve_endpoints`.
#
# ## Configuring the mailer
#
# In production you need to configure the mailer to use a real email
# sender. Here we use Mailgun/Mailjet/Network email service based on
# the configuration in environment variables.
#
# ## Configuring the database
#
# We configure the database connection using the `DATABASE_URL`
# environment variable. Alternatively, you can configure the database
# connection explicitly using the `url` option:
#
#     config :ex_venture, ExVenture.Repo,
#       url: "ecto://USER:PASS@HOST/DATABASE",
#       pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
#       ssl: System.get_env("DATABASE_SSL") == "true"
#
# See the documentation for `Ecto.Adapters.Postgres` for more options.
#
# Finally, another common approach is to use a connection string
# stored in an environment variable:
#
#     config :ex_venture, ExVenture.Repo, url: System.get_env("DATABASE_URL")
#
# Note that you may need to add the `ssl: true` option, depending
# on the database host.

# ## Configuring the host
#
# The `url` configuration below is required if you plan to run your
# application behind a proxy or load balancer. It is also useful when
# generating URLs in background jobs.
#
# Note that the `:host` option is required and you must replace `example.com`
# with your actual host. If you don't set the `:port` option, it defaults
# to 80 for http and 443 for https. If your application runs behind a
# proxy, you should configure the `:port` option to the proxy port.
# It is also recommended to configure the `:ssl` option, which specifies
# the protocol used by the proxy.
#
# Finally, you will need to update the `host` field of your endpoint
# for production environments.
#
#     config :ex_venture, Web.Endpoint,
#       url: [host: "example.com", port: 80],
#       cache_static_manifest: "priv/static/cache_manifest.json"
#
# You should replace `example.com` above with your domain.

# ## Configuring the secret key base
#
# The secret key base is used to sign/encrypt cookies and other secrets.
# A default value is used in config/dev.exs and config/test.exs but you
# want to use a different value for prod and you most likely don't want
# to check this value into version control, so we use an environment
# variable instead. You will need to set the `SECRET_KEY_BASE` environment
# variable when running your application. At least 64 bytes long is recommended.
# You can generate a new secret by running `mix phx.gen.secret`.
#
#     config :ex_venture, Web.Endpoint,
#       secret_key_base: System.get_env("SECRET_KEY_BASE")
#
# ## Using `Config.import_config/1`
#
# You can use `Config.import_config/1` to import configuration from
# other files:
#
#     import_config "prod.secret.exs"
#
# Note that import_config expects the path to be relative to the file
# that calls `import_config`. Furthermore, files imported by
# `import_config` are compiled and evaluated in the order they are read.
# If you need to import secrets that cannot be checked into version control,
# you should use `Config.read_env!/1` instead:
#
#     config :ex_venture, ExVenture.SomeService,
#       secret: System.get_env("SOME_SECRET")
#
# Alternatively, you can use `System.fetch_env!/1` if you prefer
# to fail if the environment variable is not set.

# ## Configuring the endpoint
#
# In this file, you can configure the endpoint like the
# server option below. Normally you should configure the endpoint
# based on the environment variables, like the PORT variable.
#
# However, for the sake of this example, we keep it simple.
config :ex_venture, Web.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT") || "4000")],
  # url: [host: "localhost", port: 4000], # Adjust host and port as needed
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "a_very_long_and_secure_secret_key_base_for_development_only" # Replace in production

# ## Configuring the Repo
#
# In this file, you can configure the Repo to connect to the database.
# Normally you should configure the Repo based on the environment variables,
# like the DATABASE_URL variable.
#
# However, for the sake of this example, we keep it simple.
database_url = System.get_env("DATABASE_URL") || "ecto://postgres:postgres@localhost/ex_venture_dev"

config :ex_venture, ExVenture.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
