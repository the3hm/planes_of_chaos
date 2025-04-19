defmodule Web.PageController do
  @moduledoc """
  Handles root pages, health check, and character-based client entrypoint.
  """

  use Web, :controller

  alias ExVenture.Characters

  @doc """
   Renders the homepage.
   """
   def index(conn, _params) do
     conn
     |> put_layout(html: {Web.Layouts, :simple})
     |> render(:index)
   end

   @doc """
  Returns a basic health check response.
  """
  def health(conn, _params) do
    send_resp(conn, 200, "OK")
  end

  @doc """
  Loads all characters for the current user and renders the client.

  If no characters exist, the user is prompted to create one.
  """
  def client(conn, _params) do
    %{current_user: user} = conn.assigns

    case Characters.all_for(user) do
      [] ->
        conn
        |> put_flash(:info, "Please create a character first!")
        |> redirect(to: ~p"/users/#{user.id}/profile")

      characters ->
        conn
        |> assign(:characters, characters)
        |> put_layout(html: {Web.Layouts, :simple})
        |> render(:client)
    end
  end
end
