defmodule Web.LayoutComponents do
  @moduledoc """
  Components and helpers for rendering layout-specific UI like active tabs and user context checks.
  """

  use Phoenix.Component
  import Web.Gettext

  alias Web.Router.Helpers, as: Routes
  alias ExVenture.Users

  attr :user, :map, required: true
  attr :tab, :atom, required: true
  attr :current_tab, :atom, required: true

  @doc """
  Renders a CSS class of "active" if the tab matches.
  """
  def tab_class(assigns) do
    ~H"""
    <%= if @tab == @current_tab do %>
      active
    <% else %>
      ""
    <% end %>
    """
  end

  @doc """
  Returns true if the user is an admin.
  """
  def admin?(%{admin: true}), do: true
  def admin?(_), do: false
end
