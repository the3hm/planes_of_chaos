defmodule Web.API.ZoneView do
  @moduledoc """
  JSON rendering logic for API zones.
  """

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias Web.API.Link

  @doc """
  Renders a paginated list of zones as JSON.

  Includes a self link pointing to the current page.
  """
  def render("index.json", %{pagination: pagination, zones: zones}) do
    %{
      items: Enum.map(zones, &render("show.json", %{zone: &1})),
      links: [
        %Link{
          rel: :self,
          href: ~p"/api/zones?page=#{pagination.current}"
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
          href: ~p"/api/zones/#{zone.id}"
        },
        %Link{
          rel: :rooms,
          href: ~p"/api/zones/#{zone.id}/rooms"
        }
      ]
    }
  end
end
