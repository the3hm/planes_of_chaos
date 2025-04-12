defmodule Web.Admin.StagedChangeView do
  @moduledoc """
  Component helpers for rendering staged change admin pages.
  """

  use Phoenix.Component

  import Web.Gettext
  import Web.VerifiedRoutes

  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]
  import Phoenix.HTML.Link, only: [link: 2]
  import Phoenix.Component

  alias Web.Router.Helpers, as: Routes

  alias ExVenture.Rooms.Room
  alias ExVenture.Zones.Zone

  @doc "Renders a section header for Room staged changes"
  def schema_header(%Room{}) do
    content_tag(:div, "Rooms", class: "text-center text-lg font-bold")
  end

  @doc "Renders a section header for Zone staged changes"
  def schema_header(%Zone{}) do
    content_tag(:div, "Zones", class: "text-center text-lg font-bold")
  end

  @doc "Generates a link to view a Room struct"
  def struct_link(conn, %Room{} = room) do
    link(room.name, to: Routes.admin_room_path(conn, :show, room.id))
  end

  @doc "Generates a link to view a Zone struct"
  def struct_link(conn, %Zone{} = zone) do
    link(zone.name, to: Routes.admin_zone_path(conn, :show, zone.id))
  end

  @doc "Link to delete a staged change for a Room"
  def delete_staged_change_link(conn, %{struct: %Room{}} = staged_change) do
    link("Delete",
      to: Routes.admin_staged_change_path(conn, :delete, staged_change.id, type: "room"),
      method: :delete,
      class: "text-xs btn-secondary"
    )
  end

  @doc "Link to delete a staged change for a Zone"
  def delete_staged_change_link(conn, %{struct: %Zone{}} = staged_change) do
    link("Delete",
      to: Routes.admin_staged_change_path(conn, :delete, staged_change.id, type: "zone"),
      method: :delete,
      class: "text-xs btn-secondary"
    )
  end
end
