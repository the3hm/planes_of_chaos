defmodule Web.Admin.StagedChangeView do
  @moduledoc """
  Component helpers for rendering staged change admin pages.
  """

  use Phoenix.Component

  import Phoenix.Component
  import Web.Gettext
  import Web.VerifiedRoutes

  alias Web.Router.Helpers, as: Routes
  alias ExVenture.Rooms.Room
  alias ExVenture.Zones.Zone

  @doc """
  Renders a section header for Room staged changes.

  ## Example

      <.schema_header struct={%Room{}} />
  """
  attr :struct, :map, required: true

  def schema_header(%{struct: %Room{}} = assigns) do
    ~H"""
    <div class="text-center text-lg font-bold">Rooms</div>
    """
  end

  def schema_header(%{struct: %Zone{}} = assigns) do
    ~H"""
    <div class="text-center text-lg font-bold">Zones</div>
    """
  end

  @doc """
  Renders a link to a Room or Zone struct.

  ## Example

      <.struct_link conn={@conn} struct={%Room{}} />
  """
  attr :conn, :any, required: true
  attr :struct, :map, required: true

  def struct_link(%{conn: conn, struct: %Room{} = room} = assigns) do
    ~H"""
    <a href={Routes.admin_room_path(conn, :show, room.id)} class="text-blue-500 hover:underline">
      <%= room.name %>
    </a>
    """
  end

  def struct_link(%{conn: conn, struct: %Zone{} = zone} = assigns) do
    ~H"""
    <a href={Routes.admin_zone_path(conn, :show, zone.id)} class="text-blue-500 hover:underline">
      <%= zone.name %>
    </a>
    """
  end

  @doc """
  Delete link for a staged change.

  ## Example

      <.delete_staged_change_link conn={@conn} staged_change={@staged_change} />
  """
  attr :conn, :any, required: true
  attr :staged_change, :map, required: true

  def delete_staged_change_link(%{conn: conn, staged_change: %{id: id, struct: %Room{}}} = assigns) do
    ~H"""
    <.link
      navigate={Routes.admin_staged_change_path(conn, :delete, id, type: "room")}
      method={:delete}
      class="text-xs btn-secondary"
    >
      Delete
    </.link>
    """
  end

  def delete_staged_change_link(%{conn: conn, staged_change: %{id: id, struct: %Zone{}}} = assigns) do
    ~H"""
    <.link
      navigate={Routes.admin_staged_change_path(conn, :delete, id, type: "zone")}
      method={:delete}
      class="text-xs btn-secondary"
    >
      Delete
    </.link>
    """
  end
end
