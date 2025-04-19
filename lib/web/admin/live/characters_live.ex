defmodule Web.Admin.CharactersLive do
  use Web.LiveViewBase

  alias ExVenture.Characters

  @impl true
  def mount(_params, _session, socket) do
    characters = Characters.list_all()
    {:ok,
     socket
     |> assign(:page_title, "Characters")
     |> assign(:characters, characters)
     |> assign(:selected_character, nil)
     |> assign(:show_modal, false)
     |> assign(:sort_by, :name)
     |> assign(:sort_order, :asc)
     |> assign(:search_text, "")}
  end

  @impl true
  def handle_event("search", %{"search" => %{"text" => text}}, socket) do
    filtered_characters = filter_characters(Characters.list_all(), text)

    {:noreply,
     socket
     |> assign(:search_text, text)
     |> assign(:characters, filtered_characters)}
  end

  @impl true
  def handle_event("edit_character", %{"id" => id}, socket) do
    case Characters.get(id) do
      {:ok, character} ->
        {:noreply,
         socket
         |> assign(:selected_character, character)
         |> assign(:show_modal, true)}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Character not found")}
    end
  end

  @impl true
  def handle_event("save_character", %{"character" => character_params}, socket) do
    character = socket.assigns.selected_character

    case Characters.update(character, character_params) do
      {:ok, _updated_character} ->
        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> assign(:selected_character, nil)
         |> put_flash(:info, "Character updated successfully")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:selected_character, %{character | changeset: changeset})
         |> put_flash(:error, "Failed to update character")}
    end
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:selected_character, nil)}
  end

  defp filter_characters(characters, ""), do: characters
  defp filter_characters(characters, search_text) do
    search_text = String.downcase(search_text)
    Enum.filter(characters, fn char ->
      String.contains?(String.downcase(char.name || ""), search_text)
    end)
  end

  defp character_status_color(:active), do: "badge-success"
  defp character_status_color(:banned), do: "badge-warning"
  defp character_status_color(:deleted), do: "badge-error"
  defp character_status_color(_), do: "badge-secondary"

  defp character_status_text(:active), do: "Active"
  defp character_status_text(:banned), do: "Banned"
  defp character_status_text(:deleted), do: "Deleted"
  defp character_status_text(_), do: "Unknown"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <div class="flex-1 max-w-sm">
          <.form :let={f} for={%{}} as={:search} phx-change="search" class="flex-1">
            <%= Phoenix.HTML.Form.text_input f, :text,
              value: @search_text,
              placeholder: "Search characters...",
              class: "input input-bordered w-full"
            %>
          </.form>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="table w-full">
          <thead>
            <tr>
              <th>Name</th>
              <th>User</th>
              <th>Status</th>
              <th>Created</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%= for char <- @characters do %>
              <tr id={"character-#{char.id}"}>
                <td><%= char.name %></td>
                <td><%= char.user.email %></td>
                <td>
                  <span class={"badge #{character_status_color(char.status)}"}>
                    <%= character_status_text(char.status) %>
                  </span>
                </td>
                <td><%= Calendar.strftime(char.inserted_at, "%Y-%m-%d") %></td>
                <td>
                  <.button phx-click="edit_character" phx-value-id={char.id} class="btn btn-sm btn-secondary">
                    <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Edit
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
              <.form :let={f} for={@selected_character} phx-submit="save_character">
                <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                  <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">
                    Edit Character: <%= @selected_character.name %>
                  </h3>
                  <div class="mt-4 space-y-4">
                    <div class="form-control w-full">
                      <%= Phoenix.HTML.Form.label f, :name, "Name", class: "label" %>
                      <%= Phoenix.HTML.Form.text_input f, :name, value: @selected_character.name, class: "input input-bordered w-full" %>
                      <%= Phoenix.HTML.Form.error_tag f, :name %>
                    </div>

                    <div class="form-control w-full">
                      <%= Phoenix.HTML.Form.label f, :status, "Status", class: "label" %>
                      <%= Phoenix.HTML.Form.select f, :status, [
                        {"Active", :active},
                        {"Banned", :banned},
                        {"Deleted", :deleted}
                      ], value: @selected_character.status, class: "select select-bordered w-full" %>
                      <%= Phoenix.HTML.Form.error_tag f, :status %>
                    </div>
                  </div>
                </div>
                <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                  <.button type="submit" class="btn btn-primary">
                    Save Changes
                  </.button>
                  <.button type="button" phx-click="close_modal" class="btn btn-outline ml-3">
                    Cancel
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
