defmodule Web.Admin.UsersLive do
  use Web.LiveViewBase
  import Phoenix.LiveView
  import Phoenix.Component # Ensure Phoenix.Component functions like .link are available

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
            <%= Phoenix.HTML.Form.text_input f, :text,
              value: @search_text,
              placeholder: "Search users...",
              phx_debounce: "300",
              class: "input input-bordered w-full"
            %>
          </.form>
        </div>
        <.button label="Export Users" phx-click="export_users" class="btn btn-primary">
          <.icon name="hero-arrow-down-tray" class="w-5 h-5 mr-2" /> Export Users
        </.button>
      </div>

      <div class="overflow-x-auto">
        <table class="table w-full">
          <thead>
            <tr>
              <th class="w-1/4 cursor-pointer" phx-click="sort" phx-value-field="email">Email</th>
              <th class="w-1/4 cursor-pointer" phx-click="sort" phx-value-field="username">Username</th>
              <th class="w-1/6 cursor-pointer" phx-click="sort" phx-value-field="is_admin">Admin</th>
              <th class="w-1/6 text-center">Characters</th>
              <th class="w-1/6 cursor-pointer" phx-click="sort" phx-value-field="inserted_at">Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%= for user <- @users do %>
              <tr id={"user-#{user.id}"}>
                <td class="w-1/4"><%= user.email %></td>
                <td class="w-1/4"><%= user.username %></td>
                <td class="w-1/6">
                  <span class={"badge #{if user.is_admin, do: "badge-success", else: "badge-warning"}"}>
                    <%= if user.is_admin, do: "Yes", else: "No" %>
                  </span>
                </td>
                <td class="w-1/6 text-center"><%= user.characters_count %></td>
                <td class="w-1/6"><%= Calendar.strftime(user.inserted_at, "%Y-%m-%d") %></td>
                <td>
                  <.link patch={~p"/admin/users/#{user.id}"} class="btn btn-sm btn-secondary">
                    <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> View
                  </.link>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("export_users", _params, socket) do
    # Assuming Users.export_to_csv/0 exists and returns {:ok, path} or {:error, reason}
    # And assuming Web.Admin.UserExportController handles the download
    case Users.export_to_csv() do
      {:ok, path} ->
        {:noreply,
         socket
         |> put_flash(:info, "Users exported successfully")
         |> redirect(to: ~p"/admin/users/export?path=#{path}")} # Assuming this route exists

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to export users")}
    end
  end
end
