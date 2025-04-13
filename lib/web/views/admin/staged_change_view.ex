defmodule Web.Admin.StagedChangeView do
  @moduledoc """
  Component helpers for rendering staged change admin pages.
  """

  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  import Phoenix.Component

  alias ExVenture.Rooms.Room
  alias ExVenture.Zones.Zone

  @doc """
  Renders a section header for Room or Zone staged changes.

  ## Example

      <.schema_header struct={%Room{}} />
  """
  attr :struct, :map, required: true

  def schema_header(assigns) do
    struct_type =
      case assigns.struct do
        %Room{} -> "Rooms"
        %Zone{} -> "Zones"
        _ -> "Unknown"
      end

    assigns = assign(assigns, :struct_type, struct_type)

    ~H"""
    <div class="text-center text-lg font-bold"><%= @struct_type %></div>
    """
  end

  @doc """
  Renders a link to a Room or Zone struct.

  ## Example

      <.struct_link struct={%Room{}} />
  """
  attr :struct, :map, required: true

  def struct_link(assigns) do
    case assigns.struct do
      %Room{id: id, name: name} ->
        assigns
        |> assign(:id, id)
        |> assign(:name, name)
        |> render_room_link()

      %Zone{id: id, name: name} ->
        assigns
        |> assign(:id, id)
        |> assign(:name, name)
        |> render_zone_link()

      _ ->
        ~H"<span>Unknown</span>"
    end
  end

  defp render_room_link(assigns) do
    ~H"""
    <.link navigate={~p"/admin/rooms/#{@id}"} class="text-blue-500 hover:underline">
      <%= @name %>
    </.link>
    """
  end

  defp render_zone_link(assigns) do
    ~H"""
    <.link navigate={~p"/admin/zones/#{@id}"} class="text-blue-500 hover:underline">
      <%= @name %>
    </.link>
    """
  end

  @doc """
  Delete link for a staged change with dynamic `?type=` query string.

  ## Example

      <.delete_staged_change_link staged_change={@staged_change} />
  """
  attr :staged_change, :map, required: true

  def delete_staged_change_link(assigns) do
    %{staged_change: %{id: id, struct: struct}} = assigns

    type =
      case struct do
        %Room{} -> "room"
        %Zone{} -> "zone"
        _ -> "unknown"
      end

    query_path = "/admin/staged_changes/#{id}?type=#{type}"

    assigns
    |> assign(:path, query_path)
    |> render_delete_link()
  end

  defp render_delete_link(assigns) do
    ~H"""
    <.link
      href={@path}
      method="delete"
      class="text-xs btn-secondary"
    >
      Delete
    </.link>
    """
  end
end
