defmodule Web.Plugs.EnsureAdmin do
  @moduledoc """
  Ensures the current user has admin access.
  """

  use Web, :verified_routes

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias ExVenture.Admins

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_admin(conn) do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in as an admin to access this page.")
        |> redirect(to: ~p"/admin/login")
        |> halt()

      admin ->
        Plug.Conn.assign(conn, :current_admin, admin)
    end
  end

  defp get_admin(conn) do
    cond do
      admin_id = get_session(conn, :admin_id) ->
        Admins.get_admin!(admin_id)

      admin_id = conn.params["admin_id"] ->
        admin = Admins.get_admin!(admin_id)
        # Store admin_id in session for subsequent requests
        put_session(conn, :admin_id, admin_id)
        admin

      true ->
        nil
    end
  rescue
    Ecto.NoResultsError -> nil
  end
end
