defmodule Web.Plugs.EnsureUser do
  @moduledoc """
  Ensures a user is present in the connection assigns.

  If not, redirects to the sign-in page and stores the last path for redirection after login.
  """

  import Plug.Conn
  import Phoenix.Controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  def init(default), do: default

  def call(conn, _opts) do
    case conn.assigns do
      %{current_user: current_user} when not is_nil(current_user) ->
        conn

      _ ->
        uri = %URI{path: conn.request_path, query: conn.query_string}

        conn
        |> put_flash(:info, "You must sign in first.")
        |> put_session(:last_path, URI.to_string(uri))
        |> redirect(to: ~p"/sign-in")
        |> halt()
    end
  end
end
