defmodule Web.RegistrationController do
  @moduledoc """
  Handles user registration.
  """

  use Web, :controller
  use Gettext, backend: Web.Gettext

  alias ExVenture.Users

  plug :put_layout, html: {Web.Layouts, :session}

  @doc """
  Shows the registration form.
  """
  def new(conn, _params) do
    conn
    |> assign(:changeset, Users.new())
    |> render("new.html")
  end

  @doc """
  Attempts to create a new user account.
  """
  def create(conn, %{"user" => params}) do
    case Users.create(params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Welcome to %{site}!", site: "ExVenture"))
        |> put_session(:user_token, user.token)
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("There was an error. Please try again."))
        |> put_status(:unprocessable_entity)
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end
end
