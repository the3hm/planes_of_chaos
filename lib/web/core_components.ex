defmodule Web.CoreComponents do
  @moduledoc """
  Provides reusable Phoenix components such as buttons, inputs, and other building blocks
  using Phoenix.Component and HEEx.
  """

  use Phoenix.Component

  import Web.Gettext
  alias Phoenix.LiveView.JS

  @doc """
  A basic button component.

  ## Examples

      <.button label="Click me" />
      <.button label="Delete" phx_click="delete" class="btn btn-danger" />
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
end
