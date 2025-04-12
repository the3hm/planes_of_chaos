defmodule Web.API.RoomView do
  use Phoenix.Component
use Phoenix.HTML
import Web.Gettext
import Web.CoreComponents
alias Web.Router.Helpers, as: Routes

  alias Web.Endpoint
  alias Web.API.Link

  def render("index.json", %{pagination: pagination, rooms: rooms, zone: zone}) do
    %{
      items: render_many(rooms, __MODULE__, "show.json"),
      links: [
        %Link{
          rel: :self,
          href: Routes.api_zone_room_path(Endpoint, :index, zone.id, page: pagination.current)
        }
      ]
    }
  end

  def render("index.json", %{pagination: pagination, rooms: rooms}) do
    %{
      items: render_many(rooms, __MODULE__, "show.json"),
      links: [
        %Link{
          rel: :self,
          href: Routes.api_room_path(Endpoint, :index, page: pagination.current)
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
          href: Routes.api_room_path(Endpoint, :show, room.id)
        }
      ]
    }
  end
end
