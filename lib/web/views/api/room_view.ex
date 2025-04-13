defmodule Web.API.RoomView do
  @moduledoc """
  Renders JSON responses for API room endpoints.
  """

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  defmodule Link do
    @moduledoc false
    defstruct [:rel, :href]
  end

  @doc """
  Renders JSON responses for:

    * `"index.json"` — A paginated list of rooms with optional zone scoping.
    * `"show.json"` — A single room with metadata and links.
  """
  def render("index.json", assigns) do
    %{pagination: pagination, rooms: rooms} = assigns

    %{
      items: Enum.map(rooms, &render("show.json", %{room: &1})),
      links: [
        %Link{
          rel: :self,
          href:
            if assigns[:zone] do
              ~p"/api/zones/#{assigns.zone.id}/rooms?page=#{pagination.current}"
            else
              ~p"/api/rooms?page=#{pagination.current}"
            end
        }
      ]
    }
  end

  def render("show.json", %{room: room}) do
    %{
      name: room.name,
      description: room.description,
      live?: not is_nil(room.live_at),
      links: [
        %Link{
          rel: :self,
          href: ~p"/api/rooms/#{room.id}"
        }
      ]
    }
  end
end
