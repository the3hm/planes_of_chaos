defmodule Web.Admin.RoomsLive do
  use Web.LiveViewBase
  import Phoenix.HTML.Form

  alias ExVenture.Rooms
  alias ExVenture.Zones
  alias ExVenture.StagedChanges

  @impl true
  def mount(%{"zone_id" => zone_id}, _session, socket) do
    with {:ok, zone} <- Zones.get(zone_id),
         {:ok, rooms} <- Rooms.list_by_zone(zone) do
      {:ok,
       socket
       |> assign(:page_title, "Rooms")
       |> assign(:zone, zone)
       |> assign(:rooms, rooms)
       |> assign(:selected_room, nil)
       |> assign(:show_modal, false)
       |> assign(:sort_by, :name)
       |> assign(:sort_order, :asc)
       |> assign(:search_text, "")}
    else
      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Zone not found")
         |> redirect(to: ~p"/admin/zones")}
    end
  end

  @impl true
  def handle_event("search", %{"search" => %{"text" => text}}, socket) do
    filtered_rooms = filter_rooms(socket.assigns.rooms, text)

    {:noreply,
     socket
     |> assign(:search_text, text)
     |> assign(:rooms, filtered_rooms)}
  end

  @impl true
  def handle_event("edit_room", %{"id" => id}, socket) do
    case Rooms.get(id) do
      {:ok, room} ->
        {:noreply,
         socket
         |> assign(:selected_room, room)
         |> assign(:show_modal, true)}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Room not found")}
    end
  end

  @impl true
  def handle_event("save_room", %{"room" => room_params}, socket) do
    room = socket.assigns.selected_room

    case Rooms.update(room, room_params) do
      {:ok, _updated_room} ->
        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> assign(:selected_room, nil)
         |> put_flash(:info, "Room updated successfully")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:selected_room, %{room | changeset: changeset})
         |> put_flash(:error, "Failed to update room")}
    end
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:selected_room, nil)}
  end

  defp filter_rooms(rooms, ""), do: rooms
  defp filter_rooms(rooms, search_text) do
    search_text = String.downcase(search_text)
    Enum.filter(rooms, fn room ->
      String.contains?(String.downcase(room.name || ""), search_text)
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <div class="flex items-center">
          <.link patch={~p"/admin/zones"} class="btn btn-link">
            <.icon name="hero-arrow-left" class="w-5 h-5" />
          </.link>
          <h1 class="text-2xl font-bold ml-2">Rooms in <%= @zone.name %></h1>
        </div>

        <div class="flex space-x-4">
          <div class="flex-1">
            <.form :let={f} for={%{}} as={:search} phx-change="search" class="flex-1">
              <%= Phoenix.HTML.Form.text_input f, :text,
                value: @search_text,
                placeholder: "Search rooms...",
                class: "input input-bordered w-full"
              %>
            </.form>
          </div>

          <.link patch={~p"/admin/zones/#{@zone.id}/rooms/new"} class="btn btn-primary">
            <.icon name="hero-plus" class="w-5 h-5 mr-2" /> New Room
          </.link>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="table w-full">
          <thead>
            <tr>
              <th>Name</th>
              <th>Position</th>
              <th>Status</th>
              <th>Changes</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%= for room <- @rooms do %>
              <tr id={"room-#{room.id}"}>
                <td><%= room.name %></td>
                <td>
                  X: <%= room.x %>, Y: <%= room.y %>, Z: <%= room.z %>
                </td>
                <td>
                  <span class={"badge #{if room.published, do: "badge-success", else: "badge-warning"}"}>
                    <%= if room.published, do: "Live", else: "Draft" %>
                  </span>
                </td>
                <td>
                  <%= if StagedChanges.has_changes?(room) do %>
                    <span class="badge badge-info">Has Changes</span>
                  <% end %>
                </td>
                <td class="space-x-2">
                  <.button phx-click="edit_room" phx-value-id={room.id} class="btn btn-sm btn-secondary">
                    <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Edit
                  </.button>
                  <.button phx-click="publish_room" phx-value-id={room.id} class="btn btn-sm btn-accent" disabled={room.published}>
                    <.icon name="hero-arrow-up-on-square" class="w-4 h-4 mr-1" /> Publish
                  </.button>
                  <.button phx-click="delete_room" phx-value-id={room.id} class="btn btn-sm btn-error">
                    <.icon name="hero-trash" class="w-4 h-4 mr-1" /> Delete
                  </.button>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

      <%!-- Modal Dialog --%>
      <%= if @show_modal do %>
        <div class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
          <div class="flex items-end justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:block sm:p-0">
            <%!-- Background overlay --%>
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true" phx-click="close_modal"></div>

            <%!-- Modal panel --%>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
            <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <.form :let={f} for={@selected_room} phx-submit="save_room">
                <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                  <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">
                    Edit Room: <%= @selected_room.name %>
                  </h3>
                  <div class="mt-4 space-y-4">
                    <div class="form-control w-full">
                      <%= Phoenix.HTML.Form.label f, :name, "Name", class: "label" %>
                      <%= Phoenix.HTML.Form.text_input f, :name, value: @selected_room.name, class: "input input-bordered w-full" %>
                      <%= Phoenix.HTML.Form.error_tag f, :name %>
                    </div>

                    <div class="grid grid-cols-3 gap-4">
                      <div class="form-control">
                        <%= Phoenix.HTML.Form.label f, :x, "X", class: "label" %>
                        <%= Phoenix.HTML.Form.number_input f, :x, value: @selected_room.x, class: "input input-bordered w-full" %>
                        <%= Phoenix.HTML.Form.error_tag f, :x %>
                      </div>
                      <div class="form-control">
                        <%= Phoenix.HTML.Form.label f, :y, "Y", class: "label" %>
                        <%= Phoenix.HTML.Form.number_input f, :y, value: @selected_room.y, class: "input input-bordered w-full" %>
                        <%= Phoenix.HTML.Form.error_tag f, :y %>
                      </div>
                      <div class="form-control">
                        <%= Phoenix.HTML.Form.label f, :z, "Z", class: "label" %>
                        <%= Phoenix.HTML.Form.number_input f, :z, value: @selected_room.z, class: "input input-bordered w-full" %>
                        <%= Phoenix.HTML.Form.error_tag f, :z %>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                  <.button type="button" phx-click="close_modal" class="btn btn-outline ml-3">
                    Cancel
                  </.button>
                  <.button type="submit" class="btn btn-primary">
                    Save Changes
                  </.button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
