defmodule Web.API.ZoneView do
  @moduledoc """
  JSON rendering logic for API zones.
  """

  import Web.Gettext
  alias Web.Router.Helpers, as: Routes
  alias Web.Endpoint
  alias Web.API.Link
  alias Web.API.ZoneView

  @doc "Renders paginated list of zones"
  def render("index.json", %{pagination: pagination, zones: zones}) do
    %{
      items: Enum.map(zones, &ZoneView.render("show.json", %{zone: &1})),
      links: [
        %Link{
          rel: :self,
          href: Routes.api_zone_path(Endpoint, :index, page: pagination.current)
        }
      ]
    }
  end

  @doc "Renders a single zone object"
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
