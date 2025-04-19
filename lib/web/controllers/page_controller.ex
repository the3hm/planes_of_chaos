defmodule Web.PageController do
  use Web, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def client(conn, _params) do
    characters = ExVenture.Characters.for_user(conn.assigns.current_user)
    characters_data = characters_for_client(characters)
    render(conn, :client, characters: characters_data)
  end

  def health(conn, _params) do
    send_resp(conn, 200, "ok")
  end

  # Helpers
  defp characters_for_client(characters) do
    Enum.map(characters, fn character ->
      %{
        name: character.name,
        token: Phoenix.Token.sign(Web.Endpoint, "character id", character.id)
      }
    end)
  end
end
