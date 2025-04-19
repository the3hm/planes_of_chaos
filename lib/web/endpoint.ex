defmodule Web.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :ex_venture

  @session_options [
    store: :cookie,
    key: "_ex_venture_key",
    signing_salt: "76sn4b3J"
  ]

  socket "/socket", Web.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :ex_venture,
    gzip: false,
    only_matching: ["apple", "favicon", "android"],
    only: ~w(css fonts images js favicon.ico robots.txt manifest.json)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Logster.Plugs.Logger

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session, @session_options

  if Mix.env() == :dev do
    plug(Plug.Static, at: "/uploads", from: "uploads/files")
  end

  plug Web.Router
end
