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
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(html_helpers())
    end
  end

  # -- Verified Routes ----------------------------------
  def verified_routes do
    quote do
      use Phoenix.Component
      use Phoenix.VerifiedRoutes,
        endpoint: Web.Endpoint,
        router: Web.Router,
        statics: Web.static_paths()

      import Phoenix.Controller
      import Phoenix.Component
      import Web.CoreComponents
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
      import Phoenix.LiveView.Router
    end
  end

  # -- Channel -------------------------------------------
  def channel do
    quote do
      use Phoenix.Channel
      import Web.Gettext
    end
  end

  # -- Shared HTML Helpers -------------------------------
  defp html_helpers do
    quote do
      # Core Phoenix functionality
      import Phoenix.HTML
      import Phoenix.Component

      # Route generation
      use Phoenix.VerifiedRoutes,
        endpoint: Web.Endpoint,
        router: Web.Router,
        statics: Web.static_paths()

      # Utilities and gettext
      import Web.CoreComponents
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
