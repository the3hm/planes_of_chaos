defmodule Web.Admin.UserDetailLive do
  use Web.LiveViewBase

  alias ExVenture.Users
  alias ExVenture.Characters

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    with {:ok, user} <- Users.get(id),
         {:ok, characters} <- Characters.user_characters(user.id) do
      {:ok,
       socket
       |> assign(:page_title, "User Details")
       |> assign(:user, user)
       |> assign(:characters, characters)}
    else
      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "User not found")
         |> redirect(to: ~p"/admin/users")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <%# User Profile Info Card %>
      <div class="bg-white shadow rounded-lg p-6">
        <div class="flex justify-between items-start">
          <div class="flex items-center">
            <.icon name="hero-user-circle" class="w-6 h-6 mr-2 text-dracula-purple" />
            <h2 class="text-2xl font-semibold"><%= @user.username %></h2>
          </div>
          <div class="flex space-x-2">
            <.button label="Edit" phx-click="edit_user" phx-value-id={@user.id} class="btn btn-secondary">
              <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Edit
            </.button>
            <.button label={if @user.banned_at, do: "Unban", else: "Ban"} phx-click="toggle_ban" phx-value-id={@user.id} class={if @user.banned_at, do: "btn-accent", else: "btn-error"}>
              <.icon name={if @user.banned_at, do: "hero-lock-open", else: "hero-lock-closed"} class="w-4 h-4 mr-1" />
              <%= if @user.banned_at, do: "Unban", else: "Ban" %>
            </.button>
          </div>
        </div>

        <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 class="text-sm font-medium text-gray-500">Email</h3>
            <p class="mt-1 text-sm text-gray-900"><%= @user.email %></p>
          </div>
          <div>
            <h3 class="text-sm font-medium text-gray-500">Username</h3>
            <p class="mt-1 text-sm text-gray-900"><%= @user.username %></p>
          </div>
          <div>
            <h3 class="text-sm font-medium text-gray-500">Status</h3>
            <div class="mt-1">
              <span class={"badge #{if @user.is_admin, do: "badge-success", else: "badge-secondary"}"}>
                <%= if @user.is_admin, do: "Admin", else: "User" %>
              </span>
              <%= if @user.banned_at do %>
                <span class="badge badge-error">Banned</span>
              <% end %>
            </div>
          </div>
          <div>
            <h3 class="text-sm font-medium text-gray-500">Joined</h3>
            <p class="mt-1 text-sm text-gray-900"><%= Calendar.strftime(@user.inserted_at, "%B %d, %Y") %></p>
          </div>
        </div>
      </div>

      <%# Characters List Card %>
      <div class="bg-white shadow rounded-lg p-6">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center">
            <.icon name="hero-user-group" class="w-6 h-6 mr-2 text-dracula-pink" />
            <h2 class="text-2xl font-semibold">Characters</h2>
          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="table w-full">
            <thead>
              <tr>
                <th>Name</th>
                <th>Status</th>
                <th>Created</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <%= for char <- @characters do %>
                <tr>
                  <td><%= char.name %></td>
                  <td>
                    <span class={"badge #{character_status_color(char)}"}>
                      <%= character_status(char) %>
                    </span>
                  </td>
                  <td><%= Calendar.strftime(char.inserted_at, "%Y-%m-%d") %></td>
                  <td>
                    <.link patch={~p"/admin/characters/#{char.id}"} class="btn btn-sm btn-secondary">
                      <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> View
                    </.link>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_ban", %{"id" => id}, socket) do
    user = socket.assigns.user

    case Users.toggle_ban(user) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:user, updated_user)
         |> put_flash(:info, "User #{if updated_user.banned_at, do: "banned", else: "unbanned"} successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update user ban status")}
    end
  end

  defp character_status(%{deleted_at: deleted_at}) when not is_nil(deleted_at), do: "Deleted"
  defp character_status(%{banned_at: banned_at}) when not is_nil(banned_at), do: "Banned"
  defp character_status(_), do: "Active"

  defp character_status_color(%{deleted_at: deleted_at}) when not is_nil(deleted_at), do: "badge-error"
  defp character_status_color(%{banned_at: banned_at}) when not is_nil(banned_at), do: "badge-warning"
  defp character_status_color(_), do: "badge-success"
end
