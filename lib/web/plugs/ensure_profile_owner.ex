defmodule Web.Plugs.EnsureProfileOwner do
  @moduledoc """
  Ensures the current user is only accessing their own profile via `/users/:id/profile`.

  Redirects to home if unauthorized.
  """

  import Plug.Conn
  import Phoenix.Controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  def init(opts), do: opts

  def call(%{assigns: %{current_user: %{id: user_id}}, params: %{"id" => id}} = conn, _opts) do
    if to_string(user_id) == id do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to view that profile.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
