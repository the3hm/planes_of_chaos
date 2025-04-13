defmodule Web.RegistrationController do
  @moduledoc """
  Handles user registration.
  """

  use Web, :controller
  use Gettext, backend: Web.Gettext

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Users

  plug :put_layout, {Web.Layouts, :session}

  @doc """
  Renders the registration form.
  """
  def new(conn, _params) do
    conn
    |> assign(:changeset, Users.new())
    |> render("new.html")
  end

  @doc """
  Handles user registration form submission.
  """
  def create(conn, %{"user" => params}) do
    case Users.create(params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome to #{gettext("ExVenture")}!")
        |> put_session(:user_token, user.token)
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an error. Please try again.")
        |> put_status(:unprocessable_entity)
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end
end
