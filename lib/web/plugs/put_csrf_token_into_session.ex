defmodule Web.Plugs.PutCsrfTokenIntoSession do
  @moduledoc """
  Puts the CSRF token into the session assigns for LiveView layouts.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :csrf_token, Plug.CSRFProtection.get_csrf_token())
  end
end
