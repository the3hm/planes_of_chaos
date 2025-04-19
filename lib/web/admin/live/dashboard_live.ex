defmodule Web.Admin.DashboardLive do
  use Web.LiveViewBase

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Dashboard")}
  end

  def metric(assigns) do
    ~H"""
    <div class="bg-dracula-darker rounded-lg p-4">
      <div class="flex items-center">
        <.icon name={@icon} class="w-6 h-6 text-white" />
        <div class="ml-3">
          <div class="text-sm font-medium text-gray-400"><%= @title %></div>
          <div class="text-xl font-semibold text-white"><%= @count %></div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <.metric title="Online Players" count="12" icon="hero-users" />
        <.metric title="Zones" count="4" icon="hero-map" />
        <.metric title="Rooms" count="28" icon="hero-building-library" />
      </div>

      <div class="bg-dracula-darker rounded-lg p-6 mt-6">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center">
            <.icon name="hero-cpu-chip" class="w-5 h-5 mr-2 text-dracula-purple" />
            <h2 class="text-lg font-semibold text-white">System Stats</h2>
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for {metric, _index} <- Enum.with_index([
                %{label: "Memory Usage", value: "128MB", trend: :up},
                %{label: "CPU Load", value: "2.1", trend: :down},
                %{label: "Process Count", value: "42", trend: :stable}
              ]) do %>
            <div class="bg-dracula rounded-lg p-4">
              <div class="text-sm font-medium text-gray-400"><%= metric.label %></div>
              <div class="mt-1 flex items-baseline">
                <div class="text-2xl font-semibold text-white"><%= metric.value %></div>
                <%= case metric.trend do %>
                  <% :up -> %>
                    <div class="ml-2 flex items-baseline text-sm font-semibold text-green-600">
                      <.icon name="hero-arrow-up" class="w-4 h-4" />
                    </div>
                  <% :down -> %>
                    <div class="ml-2 flex items-baseline text-sm font-semibold text-red-600">
                      <.icon name="hero-arrow-down" class="w-4 h-4" />
                    </div>
                  <% :stable -> %>
                    <div class="ml-2 flex items-baseline text-sm font-semibold text-gray-500">
                      <.icon name="hero-minus" class="w-4 h-4" />
                    </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
