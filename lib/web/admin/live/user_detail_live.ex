defmodule Web.Admin.UserDetailLive do
  use Web.LiveViewBase

  # Note: This file originally had `import Petal.Components` here,
  # which is now handled by `use Web, :live_view` via `Web.ComponentHelpers`
  # if Step 5 is done correctly.

  alias ExVenture.Users
  alias ExVenture.Characters

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Users.get_user(id) do
      {:ok, user} ->
        characters = Characters.list_by_user(user)
        {:ok,
         socket
         |> assign(:page_title, "User Details - #{user.username}")
         |> assign(:user, user)
         |> assign(:characters, characters)
         |> assign(:show_modal, false)}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "User not found")
         |> redirect(to: ~p"/admin/users")}
    end
  end

  @impl true
  def handle_event("toggle_admin", _params, socket) do
    case Users.toggle_admin(socket.assigns.user) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:user, updated_user)
         |> put_flash(:info, "User admin status updated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update user admin status")}
    end
  end

  @impl true
  def handle_event("toggle_ban", _params, socket) do
    case Users.toggle_ban(socket.assigns.user) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:user, updated_user)
         |> put_flash(:info, "User ban status updated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update user ban status")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- User Info Card -->
      <.ph_card>
        <:header>
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <.ph_icon name="hero-user-circle" class="w-6 h-6 mr-2 text-dracula-purple" />
              <h3 class="text-lg font-medium text-dracula-foreground">User Information</h3>
            </div>
            <div class="flex space-x-3">
              <.ph_button
                color={if @user.is_admin, do: "warning", else: "primary"}
                phx-click="toggle_admin"
              >
                <%= if @user.is_admin, do: "Remove Admin", else: "Make Admin" %>
              </.ph_button>
              <.ph_button
                color={if @user.banned_at, do: "success", else: "danger"}
                phx-click="toggle_ban"
              >
                <%= if @user.banned_at, do: "Unban User", else: "Ban User" %>
              </.ph_button>
            </div>
          </div>
        </:header>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="space-y-4">
            <div>
              <label class="text-sm font-medium text-dracula-comment">Username</label>
              <p class="mt-1 text-dracula-foreground"><%= @user.username %></p>
            </div>
            <div>
              <label class="text-sm font-medium text-dracula-comment">Email</label>
              <p class="mt-1 text-dracula-foreground"><%= @user.email %></p>
            </div>
            <div>
              <label class="text-sm font-medium text-dracula-comment">Joined</label>
              <p class="mt-1 text-dracula-foreground">
                <%= Calendar.strftime(@user.inserted_at, "%B %d, %Y") %>
              </p>
            </div>
          </div>
          <div class="space-y-4">
            <div>
              <label class="text-sm font-medium text-dracula-comment">Status</label>
              <div class="mt-1 flex items-center space-x-2">
                <.ph_badge color={if @user.is_admin, do: "success", else: "secondary"}>
                  <%= if @user.is_admin, do: "Admin", else: "User" %>
                </.ph_badge>
                <%= if @user.banned_at do %>
                  <.ph_badge color="danger">Banned</.ph_badge>
                <% end %>
              </div>
            </div>
            <div>
              <label class="text-sm font-medium text-dracula-comment">Last Login</label>
              <p class="mt-1 text-dracula-foreground">
                <%= if @user.last_login_at do %>
                  <%= Calendar.strftime(@user.last_login_at, "%B %d, %Y at %H:%M") %>
                <% else %>
                  Never
                <% end %>
              </p>
            </div>
          </div>
        </div>
      </.ph_card>

      <!-- Characters List -->
      <.ph_card>
        <:header>
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <.ph_icon name="hero-user-group" class="w-6 h-6 mr-2 text-dracula-pink" />
              <h3 class="text-lg font-medium text-dracula-foreground">Characters</h3>
            </div>
          </div>
        </:header>

        <.ph_table id="characters-table" rows={@characters}>
          <:col :let={char} label="Name" class="w-1/4">
            <%= char.name %>
          </:col>

          <:col :let={char} label="Class" class="w-1/4">
            <%= char.class %>
          </:col>

          <:col :let={char} label="Level" class="w-1/6 text-center">
            <%= char.level %>
          </:col>

          <:col :let={char} label="Status" class="w-1/4">
            <.ph_badge color={character_status_color(char)}>
              <%= char.status %>
            </.ph_badge>
          </:col>

          <:action :let={char}>
            <.ph_button link_type="live_patch" icon_name="hero-pencil" to={~p"/admin/characters/#{char.id}"}>
              View
            </.ph_button>
          </:action>
        </.ph_table>
      </.ph_card>
    </div>
    """
  end

  defp character_status_color(character) do
    case character.status do
      "active" -> "success"
      "inactive" -> "warning"
      "banned" -> "danger"
      _ -> "secondary"
    end
  end
end
