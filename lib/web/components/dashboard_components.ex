defmodule Web.DashboardComponents do
  @moduledoc """
  Components used in the LiveView Dashboard.
  """

  use Phoenix.Component
  import PetalComponents
  import FluxonUI.Components

  alias Phoenix.LiveView.JS

  # Container wrapper with header slot
  slot :header, required: true
  slot :content, required: true

  def dashboard_container(assigns) do
    ~H"""
    <div class="p-6 space-y-6 bg-base-100 rounded-lg shadow">
      <header class="border-b pb-4">
        <%= render_slot(@header) %>
      </header>
      <main>
        <%= render_slot(@content) %>
      </main>
    </div>
    """
  end

  # Card component used in the grid
  attr :title, :string, required: true
  attr :count, :any, required: true
  attr :icon, :string, required: true

  def card(assigns) do
    ~H"""
    <div class="bg-base-200 rounded-lg p-4 flex items-center space-x-4 shadow">
      <.icon name={@icon} class="w-6 h-6 text-primary" />
      <div>
        <div class="text-sm text-neutral-content"><%= @title %></div>
        <div class="text-xl font-bold text-base-content"><%= @count %></div>
      </div>
    </div>
    """
  end
end
