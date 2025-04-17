defmodule Web.DashboardComponents do
  @moduledoc """
  Shared layout and visual components for the Admin Dashboard.

  Includes:
    - `<.dashboard_container>`: Main dashboard wrapper with named slots.
    - `<.card>`: Compact statistic block with icon, label, and count.
    - `<.stat_grid>`: Grid layout for multiple cards.
    - `<.graph_block>`: Chart or visual module with header and slot.
    - `<.activity_feed>`: List of recent items or log entries.
  """

  use Phoenix.Component
  use Fluxon.Component
  use PetalComponents

  import PetalComponents.Icon, only: [icon: 1] # ✅ makes `<.icon>` work

  alias Phoenix.LiveView.JS

  # -- Dashboard Layout Container ----------------------------------------------

  @doc "A layout container with header and content slots for dashboard sections."
  slot :header, required: true
  slot :content, required: true

  def dashboard_container(assigns) do
    ~H"""
    <div class="p-6 space-y-6 bg-base-100 rounded-xl shadow-sm border border-base-300">
      <header class="border-b border-base-300 pb-4">
        <%= render_slot(@header) %>
      </header>
      <main class="space-y-4">
        <%= render_slot(@content) %>
      </main>
    </div>
    """
  end

  # -- Statistic Grid Wrapper --------------------------------------------------

  @doc "A responsive grid layout for multiple `<.card>` components."
  slot :inner_block, required: true

  def stat_grid(assigns) do
    ~H"""
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # -- Statistic Card ----------------------------------------------------------

  @doc "A small card for stat blocks on the dashboard grid."
  attr :title, :string, required: true
  attr :count, :any, required: true
  attr :icon, :string, required: true

  def card(assigns) do
    ~H"""
    <div class="bg-base-200 rounded-lg p-4 flex items-center gap-4 shadow-sm border border-base-300">
      <.icon name={@icon} class="w-6 h-6 text-primary" />
      <div>
        <div class="text-sm text-neutral-content font-medium"><%= @title %></div>
        <div class="text-xl font-semibold text-base-content"><%= @count %></div>
      </div>
    </div>
    """
  end

  # -- Graph Block -------------------------------------------------------------

  @doc "A content box intended to contain graphs or chart visualizations."
  slot :title, required: true
  slot :inner_block, required: true

  def graph_block(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow-sm border border-base-300 p-4">
      <h2 class="text-lg font-bold mb-2 text-base-content">
        <%= render_slot(@title) %>
      </h2>
      <div class="h-64 flex items-center justify-center text-neutral-content">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # -- Activity Feed -----------------------------------------------------------

  @doc "A vertical list of recent items or log entries."
  attr :title, :string, required: true
  attr :items, :list, default: []

  def activity_feed(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow-sm border border-base-300 p-4">
      <h2 class="text-lg font-bold mb-2 text-base-content"><%= @title %></h2>
      <ul class="space-y-2 text-sm text-base-content">
        <%= for item <- @items do %>
          <li class="border-b border-base-300 pb-1"><%= item %></li>
        <% end %>
      </ul>
    </div>
    """
  end
end
