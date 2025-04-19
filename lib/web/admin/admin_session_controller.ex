defmodule Web.Admin.AdminSessionController do
  use Web, :controller

  def delete(conn, _params) do
    conn
    |> delete_session(:admin_id)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: ~p"/admin/login")
  end
end
