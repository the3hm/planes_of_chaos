defmodule Web.Admin.UsersLive do
  use Web.LiveViewBase
  import Phoenix.LiveView
  import Phoenix.LiveView.Socket

  alias ExVenture.Users
  alias ExVenture.Users.User
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    users = Users.list_users()
    {:ok,
     socket
     |> assign(:page_title, "Users")
     |> assign(:users, users)
     |> assign(:sort_by, :email)
     |> assign(:sort_order, :asc)
     |> assign(:search_text, "")}
  end

  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    {sort_by, sort_order} = get_sort_params(field, socket.assigns.sort_by, socket.assigns.sort_order)
    sorted_users = sort_users(socket.assigns.users, sort_by, sort_order)

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_order, sort_order)
     |> assign(:users, sorted_users)}
  end

  @impl true
  def handle_event("search", %{"search" => %{"text" => text}}, socket) do
    filtered_users = filter_users(Users.list_users(), text)

    {:noreply,
     socket
     |> assign(:search_text, text)
     |> assign(:users, filtered_users)}
  end

  @impl true
  def render_table_action(assigns) do
    ~H"""
    <.ph_button link_type="live_patch" icon_name="hero-pencil" to={~p"/admin/users/#{@resource.id}"}>
      View
    </.ph_button>
    """
  end

  defp get_sort_params(field, current_sort_by, current_sort_order) do
    field = String.to_existing_atom(field)
    cond do
      field != current_sort_by -> {field, :asc}
      current_sort_order == :asc -> {field, :desc}
      true -> {field, :asc}
    end
  end

  defp sort_users(users, sort_by, sort_order) do
    Enum.sort_by(users, &Map.get(&1, sort_by), sort_order)
  end

  defp filter_users(users, ""), do: users
  defp filter_users(users, search_text) do
    search_text = String.downcase(search_text)
    Enum.filter(users, fn user ->
      String.contains?(String.downcase(user.email), search_text) ||
        String.contains?(String.downcase(user.username), search_text)
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <div class="flex-1 max-w-sm">
          <.form :let={f} for={%{}} as={:search} phx-change="search" class="flex-1">
            <.ph_input
              type="text"
              field={f[:text]}
              value={@search_text}
              placeholder="Search users..."
              phx-debounce="300"
            />
          </.form>
        </div>
        <.ph_button color="primary" phx-click="export_users">
          <.ph_icon name="hero-arrow-down-tray" class="w-5 h-5 mr-2" /> Export Users
        </.ph_button>
      </div>

      <.ph_table id="users-table" rows={@users}>
        <:col :let={user} label="Email" class="w-1/4">
          <%= user.email %>
        </:col>

        <:col :let={user} label="Username" class="w-1/4">
          <%= user.username %>
        </:col>

        <:col :let={user} label="Admin" class="w-1/6">
          <.ph_badge color={if user.is_admin, do: "success", else: "warning"}>
            <%= if user.is_admin, do: "Yes", else: "No" %>
          </.ph_badge>
        </:col>

        <:col :let={user} label="Characters" class="w-1/6 text-center">
          <%= user.characters_count %>
        </:col>

        <:col :let={user} label="Joined" class="w-1/6">
          <%= Calendar.strftime(user.inserted_at, "%Y-%m-%d") %>
        </:col>

        <:action :let={user}>
          <.ph_button link_type="live_patch" icon_name="hero-pencil" to={~p"/admin/users/#{user.id}"}>
            View
          </.ph_button>
        </:action>
      </.ph_table>
    </div>
    """
  end

  @impl true
  def handle_event("export_users", _params, socket) do
    case Users.export_to_csv() do
      {:ok, path} ->
        {:noreply,
         socket
         |> put_flash(:info, "Users exported successfully")
         |> redirect(to: ~p"/admin/users/export?path=#{path}")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to export users")}
    end
  end
end
