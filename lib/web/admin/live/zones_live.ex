defmodule Web.Admin.ZonesLive do
  use Web.LiveViewBase

  import Phoenix.LiveView.Helpers
  import Phoenix.Component

  alias Phoenix.Component.{Form}
  alias Phoenix.LiveView.JS

  alias ExVenture.Zones
  alias ExVenture.StagedChanges
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(ExVenture.PubSub, "zones")
      PubSub.subscribe(ExVenture.PubSub, "staged_changes")
    end

    zones = Zones.all() |> Map.get(:page, [])

    {:ok,
     socket
     |> assign(:page_title, "Zones")
     |> assign(:zones, zones)
     |> assign(:sort_by, :name)
     |> assign(:sort_order, :asc)
     |> assign(:search_text, "")
     |> assign(:show_form_modal, false)
     |> assign(:show_publish_modal, false)
     |> assign(:show_delete_modal, false)
     |> assign(:show_changes_modal, false)
     |> assign(:selected_zone, nil)
     |> assign(:staged_changes, [])
     |> assign(:changeset, Zones.new_changeset())
     |> assign(:action, nil)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    case socket.assigns.live_action do
      :new ->
        {:noreply,
         socket
         |> assign(:action, :new)
         |> assign(:page_title, "New Zone")
         |> assign(:show_form_modal, true)
         |> assign(:changeset, Zones.new_changeset())}

      :show ->
        {:noreply, socket}

      nil ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:zone_created, zone}, socket) do
    {:noreply, update(socket, :zones, fn zones -> [zone | zones] end)}
  end

  def handle_info({:zone_updated, updated_zone}, socket) do
    zones =
      Enum.map(socket.assigns.zones, fn zone ->
        if zone.id == updated_zone.id, do: updated_zone, else: zone
      end)

    {:noreply, assign(socket, :zones, zones)}
  end

  def handle_info({:zone_deleted, deleted_zone}, socket) do
    zones = Enum.reject(socket.assigns.zones, &(&1.id == deleted_zone.id))
    {:noreply, assign(socket, :zones, zones)}
  end

  def handle_info({:staged_changes_committed, _changes}, socket) do
    zones = Zones.all() |> Map.get(:page, [])
    {:noreply, assign(socket, :zones, zones)}
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

  @impl true
  def handle_event("search", %{"search" => %{"text" => text}}, socket) do
    filtered_zones = filter_zones(Zones.all() |> Map.get(:page, []), text)

    {:noreply,
     socket
     |> assign(:search_text, text)
     |> assign(:zones, filtered_zones)}
  end

  @impl true
  def handle_event("save", %{"zone" => zone_params}, socket) do
    case socket.assigns.action do
      :new -> create_zone(socket, zone_params)
      _ -> update_zone(socket, socket.assigns.selected_zone, zone_params)
    end
  end

  @impl true
  def handle_event("edit_zone", %{"id" => id}, socket) do
    case Zones.get(id) do
      {:ok, zone} ->
        {:noreply,
         socket
         |> assign(:action, :edit)
         |> assign(:selected_zone, zone)
         |> assign(:changeset, Zones.change_zone(zone))
         |> assign(:show_form_modal, true)}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Zone not found")}
    end
  end

  @impl true
  def handle_event("close_modal", %{"modal" => modal}, socket) do
    {:noreply,
     socket
     |> assign(:"show_#{modal}_modal", false)
     |> assign(:selected_zone, nil)
     |> assign(:changeset, Zones.new_changeset())
     |> assign(:action, nil)
     |> assign(:staged_changes, [])}
  end

  @impl true
  def handle_event("show_changes", %{"id" => id}, socket) do
    with {:ok, zone} <- Zones.get(id) do
      {:noreply,
       socket
       |> assign(:selected_zone, zone)
       |> assign(:staged_changes, zone.staged_changes)
       |> assign(:show_changes_modal, true)}
    end
  end

  def handle_event("confirm_changes", %{"id" => id}, socket) do
    with {:ok, zone} <- Zones.get(id),
         {:ok, _zone} <- StagedChanges.commit(zone) do
      {:noreply,
       socket
       |> put_flash(:info, "Changes applied successfully")
       |> assign(:show_changes_modal, false)}
    else
      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to apply changes")
         |> assign(:show_changes_modal, false)}
    end
  end

  @impl true
  def handle_event("confirm_publish", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:selected_zone, %{id: id})
     |> assign(:show_publish_modal, true)}
  end

  @impl true
  def handle_event("publish_zone", %{"id" => id}, socket) do
    with {:ok, zone} <- Zones.get(id),
         {:ok, _zone} <- Zones.publish(zone) do
      {:noreply,
       socket
       |> put_flash(:info, "Zone published successfully")
       |> assign(:show_publish_modal, false)}
    else
      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to publish zone")
         |> assign(:show_publish_modal, false)}
    end
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:selected_zone, %{id: id})
     |> assign(:show_delete_modal, true)}
  end

  @impl true
  def handle_event("delete_zone", %{"id" => id}, socket) do
    with {:ok, zone} <- Zones.get(id),
         {:ok, _zone} <- Zones.delete(zone) do
      {:noreply,
       socket
       |> put_flash(:info, "Zone deleted successfully")
       |> assign(:show_delete_modal, false)}
    else
      {:error, :published} ->
        {:noreply,
         socket
         |> put_flash(:error, "Cannot delete published zones")
         |> assign(:show_delete_modal, false)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete zone")
         |> assign(:show_delete_modal, false)}
    end
  end

  defp create_zone(socket, zone_params) do
    case Zones.create(zone_params) do
      {:ok, _zone} ->
        {:noreply,
         socket
         |> put_flash(:info, "Zone created successfully")
         |> push_patch(to: ~p"/admin/zones")
         |> assign(:show_form_modal, false)
         |> assign(:action, nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp update_zone(socket, zone, zone_params) do
    case Zones.update(zone, zone_params) do
      {:ok, _zone} ->
        {:noreply,
         socket
         |> put_flash(:info, "Zone updated successfully")
         |> assign(:show_form_modal, false)
         |> assign(:selected_zone, nil)
         |> assign(:action, nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)}
    end
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

  defp filter_zones(zones, ""), do: zones
  defp filter_zones(zones, search_text) do
    search_text = String.downcase(search_text)
    Enum.filter(zones, fn zone ->
      String.contains?(String.downcase(zone.name), search_text) ||
        String.contains?(String.downcase(zone.description || ""), search_text)
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.flash_group flash={@flash} />
      <div class="flex justify-between items-center">
        <div class="flex-1 max-w-sm">
          <.form :let={f} for={%{}} as={:search} phx-change="search" class="flex-1">
            <.input field={f[:text]} type="text" value={@search_text} placeholder="Search zones..." class="w-full" />
          </.form>
        </div>
        <.link patch={~p"/admin/zones/new"} class="btn btn-primary">
          <.icon name="hero-plus" class="w-5 h-5 mr-2" /> New Zone
        </.link>
      </div>

      <div class="overflow-x-auto">
        <table class="table w-full">
          <thead>
            <tr>
              <th class="cursor-pointer" phx-click="sort" phx-value-field="name">Name</th>
              <th>Description</th>
              <th class="cursor-pointer" phx-click="sort" phx-value-field="published">Status</th>
              <th>Changes</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%= for zone <- @zones do %>
              <tr id={"zone-#{zone.id}"}>
                <td><%= zone.name %></td>
                <td><%= zone.description %></td>
                <td>
                  <span class={"badge #{if zone.live_at, do: "badge-success", else: "badge-warning"}"}>
                    <%= if zone.live_at, do: "Live", else: "Draft" %>
                  </span>
                </td>
                <td>
                  <%= if StagedChanges.has_changes?(zone) do %>
                    <span class="badge badge-info">Has Changes</span>
                  <% end %>
                </td>
                <td class="space-x-2">
                  <div class="flex space-x-2">
                    <.link patch={~p"/admin/zones/#{zone.id}/rooms"} class="btn btn-sm btn-ghost">
                      <.icon name="hero-building-library" class="w-4 h-4 mr-1" /> Rooms
                    </.link>

                    <%= if StagedChanges.has_changes?(zone) do %>
                      <.button phx-click="show_changes" phx-value-id={zone.id} class="btn btn-sm btn-info">
                        <.icon name="hero-clock" class="w-4 h-4 mr-1" /> View Changes
                      </.button>
                    <% end %>

                    <.button phx-click="edit_zone" phx-value-id={zone.id} class="btn btn-sm btn-secondary">
                      <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Edit
                    </.button>

                    <%= if !zone.live_at do %>
                      <.button phx-click="confirm_publish" phx-value-id={zone.id} class="btn btn-sm btn-accent">
                        <.icon name="hero-arrow-up-on-square" class="w-4 h-4 mr-1" /> Publish
                      </.button>

                      <.button phx-click="confirm_delete" phx-value-id={zone.id} class="btn btn-sm btn-error">
                        <.icon name="hero-trash" class="w-4 h-4 mr-1" /> Delete
                      </.button>
                    <% end %>
                  </div>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

      <%= if @show_form_modal do %>
        <.modal on_cancel={JS.push("close_modal", value: %{modal: "form"})}>
          <.form :let={f} for={@changeset} phx-submit="save" class="space-y-6">
            <.input field={f[:name]} type="text" label="Name" required />
            <.input field={f[:key]} type="text" label="Key" required help_text="Unique identifier for the zone" />
            <.input field={f[:description]} type="textarea" label="Description" required />

            <div class="flex justify-end space-x-4">
              <.button type="button" label="Cancel" phx-click={JS.push("close_modal", value: %{modal: "form"})} class="btn btn-ghost" />
              <.button type="submit" label={if @action == :new, do: "Create Zone", else: "Update Zone"} class="btn btn-primary" />
            </div>
          </.form>
        </.modal>
      <% end %>

      <%= if @show_publish_modal do %>
        <.modal on_cancel={JS.push("close_modal", value: %{modal: "publish"})}>
          <h3 class="text-lg font-semibold mb-4">Publish Zone</h3>
          <p class="mb-6">Are you sure you want to publish this zone? Once published, changes will require staged updates.</p>
          <div class="flex justify-end space-x-4">
            <.button type="button" label="Cancel" phx-click={JS.push("close_modal", value: %{modal: "publish"})} class="btn btn-ghost" />
            <.button type="button" label="Publish" phx-click="publish_zone" phx-value-id={@selected_zone.id} class="btn btn-accent" />
          </div>
        </.modal>
      <% end %>

      <%= if @show_delete_modal do %>
        <.modal on_cancel={JS.push("close_modal", value: %{modal: "delete"})}>
          <h3 class="text-lg font-semibold mb-4">Delete Zone</h3>
          <p class="mb-6">Are you sure you want to delete this zone? This action cannot be undone.</p>
          <div class="flex justify-end space-x-4">
            <.button type="button" label="Cancel" phx-click={JS.push("close_modal", value: %{modal: "delete"})} class="btn btn-ghost" />
            <.button type="button" label="Delete" phx-click="delete_zone" phx-value-id={@selected_zone.id} class="btn btn-error" />
          </div>
        </.modal>
      <% end %>

      <%= if @show_changes_modal do %>
        <.modal on_cancel={JS.push("close_modal", value: %{modal: "changes"})}>
          <h3 class="text-lg font-semibold mb-4">Staged Changes</h3>
          <%= if Enum.empty?(@staged_changes) do %>
            <p class="text-gray-600">No staged changes.</p>
          <% else %>
            <div class="space-y-4">
              <%= for change <- @staged_changes do %>
                <div class="p-4 bg-base-200 rounded-lg">
                  <div class="flex justify-between items-start">
                    <div>
                      <p class="font-semibold"><%= change.field %></p>
                      <p class="text-sm text-gray-600">From: <%= change.from %></p>
                      <p class="text-sm text-gray-600">To: <%= change.to %></p>
                    </div>
                    <span class="text-xs text-gray-500"><%= Calendar.strftime(change.inserted_at, "%Y-%m-%d %H:%M:%S") %></span>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
          <div class="mt-6 flex justify-end space-x-4">
            <.button type="button" label="Close" phx-click={JS.push("close_modal", value: %{modal: "changes"})} class="btn btn-ghost" />
            <%= if not Enum.empty?(@staged_changes) do %>
              <.button
                type="button"
                label="Apply Changes"
                phx-click="confirm_changes"
                phx-value-id={@selected_zone.id}
                class="btn btn-primary"
              />
            <% end %>
          </div>
        </.modal>
      <% end %>
    </div>
    """
  end
end
