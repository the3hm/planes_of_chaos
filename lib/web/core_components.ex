defmodule Web.CoreComponents do
  @moduledoc """
  Provides reusable Phoenix components such as buttons, inputs, and other building blocks
  using Phoenix.Component and HEEx.
  """

  use Phoenix.Component

  import Phoenix.HTML.Form

  @doc """
  A basic button component.
  """
  attr :label, :string, required: true
  attr :phx_click, :string, default: nil
  attr :type, :string, default: "button"
  attr :class, :string, default: "btn btn-primary"
  attr :rest, :global, doc: "All additional HTML attributes"

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      phx-click={@phx_click}
      class={@class}
      {@rest}
    >
      <%= @label %>
    </button>
    """
  end

  @doc """
  A flash group component for displaying flash messages.
  """
  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <%= if @flash["info"] do %>
      <div class="alert alert-info" role="alert">
        <%= @flash["info"] %>
      </div>
    <% end %>

    <%= if @flash["error"] do %>
      <div class="alert alert-danger" role="alert">
        <%= @flash["error"] %>
      </div>
    <% end %>
    """
  end

  @doc """
  A simple icon component using Heroicons.
  """
  attr :name, :string, required: true
  attr :class, :string, default: "w-4 h-4"

  def icon(assigns) do
    ~H"""
    <svg class={@class}>
      <use href={"/assets/icons/#{@name}.svg#icon"}></use>
    </svg>
    """
  end
end
