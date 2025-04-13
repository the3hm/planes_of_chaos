defmodule Web.CharacterController do
  @moduledoc """
  Handles character creation and deletion for the current user.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Characters

  @doc """
  Creates a new character and redirects to the profile.
  """
  def create(conn, %{"character" => params}) do
    %{current_user: user} = conn.assigns

    case Characters.create(user, params) do
      {:ok, _character} ->
        conn
        |> put_flash(:info, "Character created!")
        |> redirect(to: ~p"/users/#{user.id}/profile")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was a problem creating the character")
        |> redirect(to: ~p"/users/#{user.id}/profile")
    end
  end

  @doc """
  Deletes a character and redirects to the profile.
  """
  def delete(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    {:ok, character} = Characters.get(user, id)

    case Characters.delete(character) do
      {:ok, _character} ->
        conn
        |> put_flash(:info, "Character deleted!")
        |> redirect(to: ~p"/users/#{user.id}/profile")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was a problem deleting the character")
        |> redirect(to: ~p"/users/#{user.id}/profile")
    end
  end
end
