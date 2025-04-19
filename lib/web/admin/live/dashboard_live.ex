defmodule Web.Admin.DashboardLive do
  use Web.LiveViewBase

  alias ExVenture.{Characters, Players, Rooms, Users, Zones}

  defp metric(assigns) do
    ~H"""
    <.ph_card>
      <div class="flex items-center space-x-4">
        <div class={["p-3 rounded-lg", @color]}>
          <.ph_icon name={@icon} class="w-6 h-6 text-white" />
        </div>
        <div>
          <div class="text-2xl font-semibold text-dracula-foreground">
            <%= @value %>
          </div>
          <div class="text-sm text-dracula-comment">
            <%= @label %>
          </div>
        </div>
      </div>
    </.ph_card>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(5000, self(), :update_stats)
    end

    {:ok, assign(socket, page_title: "Dashboard", stats: fetch_stats())}
  end

  @impl true
  def handle_info(:update_stats, socket) do
    {:noreply, assign(socket, stats: fetch_stats())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Stats Grid -->
      <div class="grid gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-4">
        <%= for {metric, index} <- Enum.with_index([
          %{
            value: @stats.online_players,
            label: "Online Players",
            icon: "hero-users",
            color: "bg-dracula-purple"
          },
          %{
            value: @stats.total_characters,
            label: "Total Characters",
            icon: "hero-user-group",
            color: "bg-dracula-pink"
          },
          %{
            value: @stats.zones_count,
            label: "Active Zones",
            icon: "hero-map",
            color: "bg-dracula-green"
          },
          %{
            value: @stats.rooms_count,
            label: "Total Rooms",
            icon: "hero-home",
            color: "bg-dracula-orange"
          }
        ]) do %>
          <.metric {metric} />
        <% end %>
      </div>

      <!-- System Info -->
      <.ph_card class="mt-6">
        <:header>
          <div class="flex items-center">
            <.ph_icon name="hero-cpu-chip" class="w-5 h-5 mr-2 text-dracula-purple" />
            <h3 class="text-lg font-medium text-dracula-foreground">System Information</h3>
          </div>
        </:header>
        <div class="grid gap-4 grid-cols-1 md:grid-cols-3">
          <div>
            <label class="text-sm font-medium text-dracula-comment">Uptime</label>
            <p class="mt-1 text-dracula-foreground"><%= format_uptime() %></p>
          </div>
          <div>
            <label class="text-sm font-medium text-dracula-comment">Erlang Node</label>
            <p class="mt-1 text-dracula-foreground"><%= Node.self() %></p>
          </div>
          <div>
            <label class="text-sm font-medium text-dracula-comment">Phoenix Version</label>
            <p class="mt-1 text-dracula-foreground"><%= Application.spec(:phoenix, :vsn) %></p>
          </div>
        </div>
      </.ph_card>
    </div>
    """
  end

  defp fetch_stats do
    %{
      online_players: Players.count_online(),
      total_characters: Characters.count_total(),
      zones_count: Zones.count_active(),
      rooms_count: Rooms.count_total()
    }
  end

  defp format_uptime do
    {time, _} = :erlang.statistics(:wall_clock)
    seconds = div(time, 1000)
    days = div(seconds, 86400)
    hours = div(rem(seconds, 86400), 3600)
    minutes = div(rem(seconds, 3600), 60)
    "#{days}d #{hours}h #{minutes}m"
  end
end
