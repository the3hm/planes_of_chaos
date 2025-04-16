defmodule Web.RegistrationController do
  @moduledoc """
  Handles user registration.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Users

  plug :put_layout, html: {Web.Layouts, :session}

  def new(conn, _params) do
    conn
    |> assign(:changeset, Users.new())
    |> render("new.html")
  end

  def create(conn, %{"user" => params}) do
    case Users.create(params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome to #{Gettext.gettext(Web.Gettext, "ExVenture")}!")
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
