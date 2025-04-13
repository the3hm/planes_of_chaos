defmodule Web.RegistrationResetController do
  @moduledoc """
  Handles password reset requests and token-based updates.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Users

  plug :put_layout, {Web.Layouts, :session}

  @doc """
  Renders the password reset request form.
  """
  def new(conn, _params) do
    conn
    |> assign(:changeset, Users.new())
    |> render("new.html")
  end

  @doc """
  Starts the password reset process and sends a reset link via email.
  """
  def create(conn, %{"user" => %{"email" => email}}) do
    Users.start_password_reset(email)

    conn
    |> put_flash(:info, "Password reset started! Check your inbox.")
    |> redirect(to: ~p"/sign-in")
  end

  @doc """
  Renders the password reset form using a token.
  """
  def edit(conn, %{"token" => token}) do
    conn
    |> assign(:token, token)
    |> assign(:changeset, Users.new())
    |> render("edit.html")
  end

  @doc """
  Applies the new password from the form if the token is valid.
  """
  def update(conn, %{"token" => token, "user" => params}) do
    case Users.reset_password(token, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password reset successfully!")
        |> redirect(to: ~p"/sign-in")

      _error ->
        conn
        |> put_flash(:error, "There was an issue resetting your password.")
        |> redirect(to: ~p"/sign-in")
    end
  end
end
