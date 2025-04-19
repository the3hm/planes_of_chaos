defmodule Web do
  @moduledoc """
  Entrypoint for defining your web interface (controllers, components, channels, LiveViews, etc).

  Usage examples:

      use Web, :controller
      use Web, :html
      use Web, :live_view
      use Web, :live_component
  """

  # -- Controller ---------------------------------------
  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: Web.Layouts]

      import Plug.Conn
      import Web.Gettext
      use Phoenix.VerifiedRoutes,
        endpoint: Web.Endpoint,
        router: Web.Router,
        statics: Web.static_paths()
    end
  end


  # -- HTML Components ----------------------------------
  def html do
    quote do
      # Core imports
      import Phoenix.HTML
      import Web.Gettext

      # Components & LiveView
      use Web.Components.PetalHelpers
      alias Web.Router.Helpers, as: Routes
    end
  end


  # -- LiveView Base -------------------------------------
  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {Web.Layouts, :root}

      use Web.Components.PetalHelpers
      import Web.Gettext

      # Import verified routes here
      use Phoenix.VerifiedRoutes,
        endpoint: Web.Endpoint,
        router: Web.Router,
        statics: Web.static_paths()
    end
  end

  # -- LiveComponent Base --------------------------------
  def live_component do
    quote do
      use Phoenix.LiveComponent

      use Web.Components.PetalHelpers
      import Web.Gettext
      alias Web.Router.Helpers, as: Routes
    end
  end

  # -- Router --------------------------------------------
  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router # ✅ Required for `live` macro
    end
  end

  # -- Channel -------------------------------------------
  def channel do
    quote do
      use Phoenix.Channel
      import Web.Gettext
    end
  end

  # -- Static assets -------------------------------------
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  # -- Dispatch Macro -------------------------------------
  @doc """
  Dispatch to the appropriate module with: `use Web, :controller`, etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
