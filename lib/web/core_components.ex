defmodule Web.CoreComponents do
  @moduledoc """
  Provides reusable Phoenix components such as buttons, inputs, etc.
  """

  use Phoenix.Component
  use Phoenix.HTML

  import Web.Gettext
  alias Phoenix.LiveView.JS

  @doc "Simple button component"
  attr :label, :string, required: true
  attr :phx_click, :string, default: nil
  attr :type, :string, default: "button"
  attr :class, :string, default: "btn btn-primary"

  def button(assigns) do
    ~H"""
    <button type={@type} phx-click={@phx_click} class={@class}>
      <%= @label %>
    </button>
    """
  end
end
