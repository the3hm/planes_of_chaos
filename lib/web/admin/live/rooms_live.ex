defmodule Web.Admin.RoomsLive do
  use Web.LiveViewBase

  alias ExVenture.Rooms
  alias ExVenture.Rooms.Room
  alias ExVenture.Zones
  alias ExVenture.StagedChanges
  alias Phoenix.LiveView.JS
  alias Phoenix.PubSub

  @impl true
  def mount(%{"zone_id" => zone_id}, _session, socket) do
    case Zones.get_zone(zone_id) do
      {:ok, zone} ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(ExVenture.PubSub, "staged_changes")
        end

        {:ok,
         socket
         |> assign(:page_title, "Rooms - #{zone.name}")
         |> assign(:zone, zone)
         |> assign(:rooms, Rooms.list_rooms_by_zone(zone_id))
         |> assign(:show_modal, false)
         |> assign(:selected_room, nil)
         |> assign(:sort_by, :name)
         |> assign(:sort_order, :asc)
         |> assign(:search_text, "")
         |> assign_staged_changes()}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Zone not found")
         |> redirect(to: ~p"/admin/zones")}
    end
  end

  @impl true
  def handle_info({:staged_changes_updated, _changes}, socket) do
    {:noreply, assign_staged_changes(socket)}
  end

  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    {sort_by, sort_order} = get_sort_params(field, socket.assigns.sort_by, socket.assigns.sort_order)
    sorted_rooms = sort_rooms(socket.assigns.rooms, sort_by, sort_order)

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_order, sort_order)
     |> assign(:rooms, sorted_rooms)}
  end

  defp get_sort_params(field, current_sort_by, current_sort_order) do
    field = String.to_existing_atom(field)
    cond do
      field != current_sort_by -> {field, :asc}
      current_sort_order == :asc -> {field, :desc}
      true -> {field, :asc}
    end
  end

  defp sort_rooms(rooms, sort_by, sort_order) do
    Enum.sort_by(rooms, &Map.get(&1, sort_by), sort_order)
  end

  @impl true
  def handle_event("search", %{"search" => %{"text" => text}}, socket) do
    filtered_rooms = filter_by_search(socket.assigns.rooms, text)

    {:noreply,
     socket
     |> assign(:search_text, text)
     |> assign(:rooms, filtered_rooms)}
  end

  defp filter_by_search(rooms, ""), do: rooms
  defp filter_by_search(rooms, search_text) do
    search_text = String.downcase(search_text)
    Enum.filter(rooms, fn room ->
      String.contains?(String.downcase(room.name), search_text) ||
        String.contains?(String.downcase(room.description), search_text)
    end)
  end


  @impl true
  def handle_event("edit_room", %{"id" => id}, socket) do
    case Rooms.get_room(id) do
      {:ok, room} ->
        {:noreply,
         socket
         |> assign(:selected_room, room)
         |> assign(:show_modal, true)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Room not found")}
    end
  end

  @impl true
  def handle_event("save_room", %{"room" => params}, socket) do
    case Rooms.update_room(socket.assigns.selected_room, params) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> assign(:selected_room, nil)
         |> put_flash(:info, "Room updated successfully")
         |> assign(:rooms, Rooms.list_rooms_by_zone(socket.assigns.zone.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Error updating room")}
    end
  end

  @impl true
  def handle_event("publish_room", %{"id" => id}, socket) do
    case Rooms.publish_room(id) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> put_flash(:info, "Room published successfully")
         |> assign(:rooms, Rooms.list_rooms_by_zone(socket.assigns.zone.id))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to publish room")}
    end
  end

  @impl true
  def handle_event("delete_changes", %{"id" => id}, socket) do
    case StagedChanges.delete_room_changes(id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Staged changes deleted successfully")
         |> assign_staged_changes()}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to delete staged changes")}
    end
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:selected_room, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex flex-col space-y-4 md:space-y-0 md:flex-row md:justify-between md:items-center mb-6">
        <div class="flex items-center space-x-2">
          <.link
            navigate={~p"/admin/zones"}
            class="text-dracula-purple hover:text-dracula-pink"
          >
            <.ph_icon name="hero-arrow-left" class="w-5 h-5" />
          </.link>
          <h3 class="text-lg font-medium text-dracula-foreground">
            <%= @zone.name %> - Rooms
          </h3>
        </div>

        <div class="flex items-center space-x-4">
          <div class="w-64">
            <.form :let={f} for={%{}} as={:search} phx-change="search">
              <.ph_input
                type="text"
                field={f[:text]}
                value={@search_text}
                placeholder="Search rooms..."
                phx-debounce="300"
              />
            </.form>
          </div>

          <.ph_button color="primary" link_type="live_patch" to={~p"/admin/zones/#{@zone.id}/rooms/new"}>
            <.ph_icon name="hero-plus" class="w-5 h-5 mr-2" /> New Room
          </.ph_button>
        </div>
      </div>

      <.ph_table
        id="rooms-table"
        rows={@rooms}
        row_click={fn room -> JS.push("edit_room", value: %{id: room.id}) end}
      >
        <:col :let={room} label="Name" class="w-1/4">
          <%= room.name %>
        </:col>

        <:col :let={room} label="Description" class="w-1/3">
          <div class="truncate max-w-md">
            <%= room.description %>
          </div>
        </:col>

        <:col :let={room} label="Status" class="w-1/6">
          <div class="flex items-center space-x-2">
            <.ph_badge color={if room.published, do: "success", else: "warning"}>
              <%= if room.published, do: "Published", else: "Draft" %>
            </.ph_badge>
            <%= if has_staged_changes?(room.id, @staged_changes) do %>
              <.ph_badge color="info">Has Changes</.ph_badge>
            <% end %>
          </div>
        </:col>

        <:col :let={room} label="Location" class="w-1/6 font-mono text-center">
          (<%= room.x %>, <%= room.y %>, <%= room.z %>)
        </:col>

        <:action :let={room}>
          <div class="flex items-center space-x-2">
            <%= if has_staged_changes?(room.id, @staged_changes) do %>
              <.ph_button
                color="danger"
                size="sm"
                phx-click="delete_changes"
                phx-value-id={room.id}
              >
                Discard Changes
              </.ph_button>
            <% end %>

            <%= unless room.published do %>
              <.ph_button
                color="success"
                size="sm"
                phx-click="publish_room"
                phx-value-id={room.id}
              >
                Publish
              </.ph_button>
            <% end %>

            <.ph_button
              color="secondary"
              size="sm"
              phx-click="edit_room"
              phx-value-id={room.id}
              icon_name="hero-pencil"
            >
              Edit
            </.ph_button>
          </div>
        </:action>
      </.ph_table>


      <.ph_modal :if={@show_modal} id="edit-room-modal" show={@show_modal} on_close="close_modal">
        <:title>Edit Room</:title>

        <.form for={%{}} phx-submit="save_room" class="space-y-4">
          <div>
            <.ph_input type="text" label="Name" name="room[name]" value={@selected_room.name} />
          </div>
          <div>
            <.ph_input
              type="textarea"
              label="Description"
              name="room[description]"
              value={@selected_room.description}
            />
          </div>
          <div class="grid grid-cols-3 gap-4">
            <div>
              <.ph_input type="number" label="X" name="room[x]" value={@selected_room.x} />
            </div>
            <div>
              <.ph_input type="number" label="Y" name="room[y]" value={@selected_room.y} />
            </div>
            <div>
              <.ph_input type="number" label="Z" name="room[z]" value={@selected_room.z} />
            </div>
          </div>

          <div class="mt-6 flex justify-end space-x-3">
            <.ph_button type="button" variant="outline" phx-click="close_modal">
              Cancel
            </.ph_button>
            <.ph_button type="submit" color="primary">
              Save Changes
            </.ph_button>
          </div>
        </.form>
      </.ph_modal>
    </div>
    """
  end

  defp assign_staged_changes(socket) do
    changes = StagedChanges.list_room_changes(socket.assigns.zone.id)
    assign(socket, staged_changes: changes)
  end

  defp has_staged_changes?(room_id, staged_changes) do
    Enum.any?(staged_changes, &(&1.room_id == room_id))
  end
end
