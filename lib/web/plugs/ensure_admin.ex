defmodule Web.Plugs.EnsureAdmin do
  @moduledoc """
  Plug to ensure the current user has admin privileges.
  """

  import Plug.Conn
  import Phoenix.Controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Users

  def init(default), do: default

  def call(conn, _opts) do
    %{current_user: user} = conn.assigns

    case Users.admin?(user) do
      true ->
        conn

      false ->
        conn
        |> put_flash(:error, "You are not an admin.")
        |> redirect(to: ~p"/")
        |> halt()
    end
  end
end
