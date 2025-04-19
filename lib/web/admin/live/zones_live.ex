defmodule Web.Admin.ZonesLive do
  use Web.LiveViewBase

  alias ExVenture.Zones
  alias ExVenture.Zones.Zone
  alias ExVenture.StagedChanges
  alias Phoenix.LiveView.JS
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(ExVenture.PubSub, "staged_changes")
    end

    {:ok,
     socket
     |> assign(:page_title, "Zones")
     |> assign(:zones, Zones.list_zones())
     |> assign(:show_modal, false)
     |> assign(:selected_zone, nil)
     |> assign(:sort_by, :name)
     |> assign(:sort_order, :asc)
     |> assign(:search_text, "")
     |> assign(:has_staged_changes, false)
     |> assign_staged_changes()}
  end

  @impl true
  def handle_info({:staged_changes_updated, _changes}, socket) do
    {:noreply, assign_staged_changes(socket)}
  end

  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    {sort_by, sort_order} = get_sort_params(field, socket.assigns.sort_by, socket.assigns.sort_order)
    sorted_zones = sort_zones(socket.assigns.zones, sort_by, sort_order)

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_order, sort_order)
     |> assign(:zones, sorted_zones)}
  end

  defp get_sort_params(field, current_sort_by, current_sort_order) do
    field = String.to_existing_atom(field)
    cond do
      field != current_sort_by -> {field, :asc}
      current_sort_order == :asc -> {field, :desc}
      true -> {field, :asc}
    end
  end

  defp sort_zones(zones, sort_by, sort_order) do
    Enum.sort_by(zones, &Map.get(&1, sort_by), sort_order)
  end

  @impl true
  def handle_event("search", %{"search" => %{"text" => text}}, socket) do
    filtered_zones = filter_by_search(Zones.list_zones(), text)

    {:noreply,
     socket
     |> assign(:search_text, text)
     |> assign(:zones, filtered_zones)}
  end

  defp filter_by_search(zones, ""), do: zones
  defp filter_by_search(zones, search_text) do
    search_text = String.downcase(search_text)
    Enum.filter(zones, fn zone ->
      String.contains?(String.downcase(zone.name), search_text) ||
        String.contains?(String.downcase(zone.description), search_text) ||
        String.contains?(String.downcase(zone.owner.email), search_text)
    end)
  end

  @impl true
  def handle_event("edit_zone", %{"id" => id}, socket) do
    case Zones.get_zone(id) do
      {:ok, zone} ->
        {:noreply,
         socket
         |> assign(:selected_zone, zone)
         |> assign(:show_modal, true)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Zone not found")}
    end
  end

  @impl true
  def handle_event("save_zone", %{"zone" => params}, socket) do
    case Zones.update_zone(socket.assigns.selected_zone, params) do
      {:ok, _zone} ->
        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> assign(:selected_zone, nil)
         |> put_flash(:info, "Zone updated successfully")
         |> assign(:zones, Zones.list_zones())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Error updating zone")}
    end
  end

  @impl true
  def handle_event("publish_zone", %{"id" => id}, socket) do
    case Zones.publish_zone(id) do
      {:ok, _zone} ->
        {:noreply,
         socket
         |> put_flash(:info, "Zone published successfully")
         |> assign(:zones, Zones.list_zones())}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to publish zone")}
    end
  end

  @impl true
  def handle_event("delete_changes", %{"id" => id}, socket) do
    case StagedChanges.delete_zone_changes(id) do
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
     |> assign(:selected_zone, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center mb-6">
        <div class="flex-1 max-w-sm">
          <.form :let={f} for={%{}} as={:search} phx-change="search">
            <.ph_input
              type="text"
              field={f[:text]}
              value={@search_text}
              placeholder="Search zones..."
              phx-debounce="300"
            />
          </.form>
        </div>

        <.ph_button color="primary" link_type="live_patch" to={~p"/admin/zones/new"}>
          <.ph_icon name="hero-plus" class="w-5 h-5 mr-2" /> New Zone
        </.ph_button>
      </div>

      <.ph_table
        id="zones-table"
        rows={@zones}
        row_click={fn zone -> JS.push("edit_zone", value: %{id: zone.id}) end}
      >
        <:col :let={zone} label="Name" class="w-1/4">
          <%= zone.name %>
        </:col>

        <:col :let={zone} label="Description" class="w-1/3">
          <div class="truncate max-w-md">
            <%= zone.description %>
          </div>
        </:col>

        <:col :let={zone} label="Status" class="w-1/6">
          <div class="flex items-center space-x-2">
            <.ph_badge color={if zone.published, do: "success", else: "warning"}>
              <%= if zone.published, do: "Published", else: "Draft" %>
            </.ph_badge>
            <%= if has_staged_changes?(zone.id, @staged_changes) do %>
              <.ph_badge color="info">Has Changes</.ph_badge>
            <% end %>
          </div>
        </:col>

        <:col :let={zone} label="Rooms" class="w-1/6 text-center">
          <%= zone.rooms_count %>
        </:col>

        <:col :let={zone} label="Owner" class="w-1/6">
          <%= zone.owner.email %>
        </:col>

        <:action :let={zone}>
          <div class="flex items-center space-x-2">
            <%= if has_staged_changes?(zone.id, @staged_changes) do %>
              <.ph_button
                color="danger"
                size="sm"
                phx-click="delete_changes"
                phx-value-id={zone.id}
              >
                Discard Changes
              </.ph_button>
            <% end %>

            <%= unless zone.published do %>
              <.ph_button
                color="success"
                size="sm"
                phx-click="publish_zone"
                phx-value-id={zone.id}
              >
                Publish
              </.ph_button>
            <% end %>

            <.ph_button
              color="secondary"
              size="sm"
              phx-click="edit_zone"
              phx-value-id={zone.id}
              icon_name="hero-pencil"
            >
              Edit
            </.ph_button>
          </div>
        </:action>
      </.ph_table>


      <.ph_modal :if={@show_modal} id="edit-zone-modal" show={@show_modal} on_close="close_modal">
        <:title>Edit Zone</:title>

        <.form for={%{}} phx-submit="save_zone" class="space-y-4">
          <div>
            <.ph_input type="text" label="Name" name="zone[name]" value={@selected_zone.name} />
          </div>
          <div>
            <.ph_input
              type="textarea"
              label="Description"
              name="zone[description]"
              value={@selected_zone.description}
            />
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
    changes = StagedChanges.list_zone_changes()
    assign(socket, staged_changes: changes)
  end

  defp has_staged_changes?(zone_id, staged_changes) do
    Enum.any?(staged_changes, &(&1.zone_id == zone_id))
  end
end
