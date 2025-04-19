defmodule Web.Admin.CharactersLive do
  use Web.LiveViewBase

  alias ExVenture.Characters
  alias ExVenture.Characters.Character
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    characters = Characters.list_characters()
    {:ok,
     socket
     |> assign(:page_title, "Characters")
     |> assign(:characters, characters)
     |> assign(:filters, initial_filters())
     |> assign(:show_modal, false)
     |> assign(:selected_character, nil)
     |> assign(:sort_by, :name)
     |> assign(:sort_order, :asc)
     |> assign(:search_text, "")}
  end

  defp initial_filters do
    %{
      class: nil,
      level_min: nil,
      level_max: nil,
      status: nil
    }
  end

  defp class_options do
    [
      "Warrior",
      "Mage",
      "Rogue",
      "Cleric",
      "Ranger"
    ]
  end

  defp status_options do
    [
      "active",
      "inactive",
      "banned"
    ]
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    filtered_chars = apply_filters(Characters.list_characters(), filters)
    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:characters, filtered_chars)}
  end

  defp apply_filters(characters, filters) do
    characters
    |> filter_by_class(filters["class"])
    |> filter_by_level(filters["level_min"], filters["level_max"])
    |> filter_by_status(filters["status"])
  end

  defp filter_by_class(characters, nil), do: characters
  defp filter_by_class(characters, ""), do: characters
  defp filter_by_class(characters, class) do
    Enum.filter(characters, & &1.class == class)
  end

  defp filter_by_level(characters, min, max) do
    characters
    |> filter_by_min_level(min)
    |> filter_by_max_level(max)
  end

  defp filter_by_min_level(characters, nil), do: characters
  defp filter_by_min_level(characters, ""), do: characters
  defp filter_by_min_level(characters, min) do
    min = String.to_integer(min)
    Enum.filter(characters, & &1.level >= min)
  end

  defp filter_by_max_level(characters, nil), do: characters
  defp filter_by_max_level(characters, ""), do: characters
  defp filter_by_max_level(characters, max) do
    max = String.to_integer(max)
    Enum.filter(characters, & &1.level <= max)
  end

  defp filter_by_status(characters, nil), do: characters
  defp filter_by_status(characters, ""), do: characters
  defp filter_by_status(characters, status) do
    Enum.filter(characters, & &1.status == status)
  end

  @impl true
  def handle_event("edit_character", %{"id" => id}, socket) do
    case Characters.get_character(id) do
      {:ok, character} ->
        {:noreply,
         socket
         |> assign(:selected_character, character)
         |> assign(:show_modal, true)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Character not found")}
    end
  end

  @impl true
  def handle_event("save_character", %{"character" => params}, socket) do
    case Characters.update_character(socket.assigns.selected_character, params) do
      {:ok, character} ->
        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> assign(:selected_character, nil)
         |> put_flash(:info, "Character updated successfully")
         |> assign(:characters, Characters.list_characters())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Error updating character")}
    end
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:selected_character, nil)}
  end

  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    {sort_by, sort_order} = get_sort_params(field, socket.assigns.sort_by, socket.assigns.sort_order)
    sorted_chars = sort_characters(socket.assigns.characters, sort_by, sort_order)

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_order, sort_order)
     |> assign(:characters, sorted_chars)}
  end

  defp get_sort_params(field, current_sort_by, current_sort_order) do
    field = String.to_existing_atom(field)
    cond do
      field != current_sort_by -> {field, :asc}
      current_sort_order == :asc -> {field, :desc}
      true -> {field, :asc}
    end
  end

  defp sort_characters(characters, sort_by, sort_order) do
    Enum.sort_by(characters, &Map.get(&1, sort_by), sort_order)
  end

  @impl true
  def handle_event("search", %{"search" => %{"text" => text}}, socket) do
    filtered_chars = filter_by_search(Characters.list_characters(), text)

    {:noreply,
     socket
     |> assign(:search_text, text)
     |> assign(:characters, filtered_chars)}
  end

  defp filter_by_search(characters, ""), do: characters
  defp filter_by_search(characters, search_text) do
    search_text = String.downcase(search_text)
    Enum.filter(characters, fn char ->
      String.contains?(String.downcase(char.name), search_text) ||
        String.contains?(String.downcase(char.user.email), search_text)
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
        <.form for={%{}} phx-change="filter" class="grid grid-cols-1 md:grid-cols-4 gap-4 flex-grow">
          <div class="w-full">
            <.ph_input
              type="select"
              name="filters[class]"
              value={@filters.class}
              options={class_options()}
              prompt="Filter by Class"
            />
          </div>
          <div class="w-full">
            <.ph_input
              type="select"
              name="filters[status]"
              value={@filters.status}
              options={status_options()}
              prompt="Filter by Status"
            />
          </div>
          <div class="w-full">
            <.ph_input
              type="number"
              name="filters[level_min]"
              value={@filters.level_min}
              placeholder="Min Level"
            />
          </div>
          <div class="w-full">
            <.ph_input
              type="number"
              name="filters[level_max]"
              value={@filters.level_max}
              placeholder="Max Level"
            />
          </div>
        </.form>

        <div class="w-full md:w-64">
          <.form :let={f} for={%{}} as={:search} phx-change="search">
            <.ph_input
              type="text"
              field={f[:text]}
              value={@search_text}
              placeholder="Search characters..."
              phx-debounce="300"
            />
          </.form>
        </div>
      </div>

      <.ph_table
        id="characters-table"
        rows={@characters}
        row_click={fn char -> JS.push("edit_character", value: %{id: char.id}) end}
      >
        <:col :let={char} label="Name" class="w-1/5">
          <%= char.name %>
        </:col>

        <:col :let={char} label="Class" class="w-1/5">
          <%= char.class %>
        </:col>

        <:col :let={char} label="Level" class="w-1/6 text-center">
          <%= char.level %>
        </:col>

        <:col :let={char} label="Status" class="w-1/5">
          <.ph_badge color={character_status_color(char.status)}>
            <%= char.status %>
          </.ph_badge>
        </:col>

        <:col :let={char} label="User" class="w-1/5">
          <%= char.user.email %>
        </:col>

        <:action :let={char}>
          <.ph_button phx-click="edit_character" phx-value-id={char.id} icon_name="hero-pencil">
            Edit
          </.ph_button>
        </:action>
      </.ph_table>


      <.ph_modal :if={@show_modal} id="edit-character-modal" show={@show_modal} on_close="close_modal">
        <:title>Edit Character</:title>

        <.form for={%{}} phx-submit="save_character" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <.ph_input type="text" label="Name" name="character[name]" value={@selected_character.name} />
            </div>
            <div>
              <.ph_input
                type="select"
                label="Status"
                name="character[status]"
                value={@selected_character.status}
                options={status_options()}
              />
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <.ph_input
                type="select"
                label="Class"
                name="character[class]"
                value={@selected_character.class}
                options={class_options()}
              />
            </div>
            <div>
              <.ph_input
                type="number"
                label="Level"
                name="character[level]"
                value={@selected_character.level}
              />
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

  defp character_status_color(status) do
    case status do
      "active" -> "success"
      "inactive" -> "warning"
      "banned" -> "danger"
      _ -> "secondary"
    end
  end
end
