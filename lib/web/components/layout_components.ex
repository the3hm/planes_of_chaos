defmodule Web.LayoutComponents do
  @moduledoc """
  Components and helpers for rendering layout-specific UI like active tabs and meta tags.
  """

  use Phoenix.Component
  use Gettext, backend: Web.Gettext

  # -- ATTRIBUTES ----------------------------------------

  attr :user, :map, required: true
  attr :tab, :atom, required: true
  attr :current_tab, :atom, required: true

  # -- COMPONENTS ----------------------------------------

  @doc """
  Renders a CSS class of `"active"` if the tab matches the current tab.
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
  Renders favicon and icon tags for browser and devices.
  """
  def icons(assigns) do
    ~H"""
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-icon-57x57.png" />
    <link rel="apple-touch-icon" sizes="60x60" href="/apple-icon-60x60.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-icon-72x72.png" />
    <link rel="apple-touch-icon" sizes="76x76" href="/apple-icon-76x76.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-icon-114x114.png" />
    <link rel="apple-touch-icon" sizes="120x120" href="/apple-icon-120x120.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-icon-144x144.png" />
    <link rel="apple-touch-icon" sizes="152x152" href="/apple-icon-152x152.png" />
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-icon-180x180.png" />
    <link rel="icon" type="image/png" sizes="192x192" href="/android-icon-192x192.png" />
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
    <link rel="icon" type="image/png" sizes="96x96" href="/favicon-96x96.png" />
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
    <link rel="manifest" href="/manifest.json" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="msapplication-TileImage" content="/ms-icon-144x144.png" />
    <meta name="theme-color" content="#ffffff" />
    """
  end

  @doc """
  Renders Open Graph and Twitter Card metadata tags.
  """
  def social_meta(assigns) do
    ~H"""
    <meta property="og:site_name" content={gettext("ExVenture")} />

    <%= if assigns[:open_graph_title] do %>
      <meta property="og:title" content={@open_graph_title} />
    <% end %>

    <%= if assigns[:open_graph_description] do %>
      <meta property="og:description" content={@open_graph_description} />
    <% end %>

    <%= if assigns[:open_graph_url] do %>
      <meta property="og:url" content={@open_graph_url} />
    <% end %>

    <meta name="twitter:card" content="summary" />
    """
  end

  @doc """
  Returns true if the user is marked as admin.
  """
  def admin?(%{admin: true}), do: true
  def admin?(_), do: false
end
