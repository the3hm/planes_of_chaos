defmodule Web.DashboardLive do
  @moduledoc """
  LiveView admin dashboard, showing real-time status cards.

  Uses `Web.DashboardComponents` to display:
  - Online player count
  - Zone count
  - Room count
  """

  use Web, :live_view

  import PetalComponents.Button
  import Web.DashboardComponents


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.dashboard_container>
      <:header>
        <div class="flex justify-between items-center">
          <h1 class="text-2xl font-bold">Dashboard</h1>
          <.button icon="plus">New Action</.button>
        </div>
      </:header>

      <:content>
        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          <.card title="Online Players" count="12" icon="users" />
          <.card title="Zones Loaded" count="4" icon="map" />
          <.card title="Rooms" count="28" icon="home" />
        </div>
      </:content>
    </.dashboard_container>
    """
  end
end
