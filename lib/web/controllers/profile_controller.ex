defmodule Web.ProfileController do
  @moduledoc """
  Handles user profile editing and character listing.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Characters
  alias ExVenture.Users

  @doc """
  Displays the profile page with all of the user's characters.
  """
  def show(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> assign(:characters, Characters.all_for(user))
    |> render("show.html")
  end

  @doc """
  Renders the profile edit form.
  """
  def edit(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> assign(:changeset, Users.edit(user))
    |> render("edit.html")
  end

  @doc """
  Updates the user's password if the current password is provided.
  Otherwise, updates the rest of the profile fields.
  """
  def update(conn, %{"user" => %{"current_password" => password} = params}) do
    %{current_user: user} = conn.assigns

    case Users.change_password(user, password, params) do
      {:ok, _updated_user} ->
        conn
        |> put_flash(:info, "Password updated.")
        |> redirect(to: ~p"/users/#{user.id}/profile")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not update your password.")
        |> redirect(to: ~p"/users/#{user.id}/profile/edit")
    end
  end

  def update(conn, %{"user" => params}) do
    %{current_user: user} = conn.assigns

    case Users.update(user, params) do
      {:ok, _updated_user} ->
        conn
        |> put_flash(:info, "Profile updated")
        |> redirect(to: ~p"/users/#{user.id}/profile")

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> render("edit.html")
    end
  end
end
