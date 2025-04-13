defmodule Web.SessionController do
  @moduledoc """
  Handles user session login/logout logic.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Users

  @doc """
  Renders the sign-in form.
  """
  def new(conn, _params) do
    conn
    |> put_layout([{:html, {Web.Layouts, :session}}]) # ✅ Fixed: wrap layout in a list
    |> assign(:changeset, Users.change_user_changeset())
    |> render("new.html")
  end

  @doc """
  Handles login credentials and redirects to homepage or last visited path.
  """
  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Users.validate_login(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "You have signed in.")
        |> put_session(:user_token, user.token)
        |> after_sign_in_redirect(~p"/")

      {:error, :invalid} ->
        conn
        |> put_flash(:error, "Your email or password is invalid")
        |> redirect(to: ~p"/sign-in")
    end
  end

  @doc """
  Logs out the user by clearing session and redirecting to homepage.
  """
  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/")
  end

  @doc """
  Redirect to the last visited page if available, otherwise use the default.
  """
  def after_sign_in_redirect(conn, default_path) do
    case get_session(conn, :last_path) do
      nil -> redirect(conn, to: default_path)
      path ->
        conn
        |> put_session(:last_path, nil)
        |> redirect(to: path)
    end
  end
end
