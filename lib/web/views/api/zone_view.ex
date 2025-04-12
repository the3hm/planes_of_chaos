defmodule Web.API.ZoneView do
  use Phoenix.Component
use Phoenix.HTML
import Web.Gettext
import Web.CoreComponents
alias Web.Router.Helpers, as: Routes

  alias Web.Endpoint
  alias Web.API.Link

  def render("index.json", %{pagination: pagination, zones: zones}) do
    %{
      items: render_many(zones, __MODULE__, "show.json"),
      links: [
        %Link{
          rel: :self,
          href: Routes.api_zone_path(Endpoint, :index, page: pagination.current)
        }
      ]
    }
  end

  def render("show.json", %{zone: zone}) do
    %{
      name: zone.name,
      live?: not is_nil(zone.live_at),
      links: [
        %Link{
          rel: :self,
          href: Routes.api_zone_path(Endpoint, :show, zone.id)
        },
        %Link{
          rel: :rooms,
          href: Routes.api_zone_room_path(Endpoint, :index, zone.id)
        }
      ]
    }
  end
end
