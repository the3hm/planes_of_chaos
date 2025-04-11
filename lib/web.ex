defmodule Web do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels and so on.

  This can be used in your application as:

      use Web, :controller
      use Web, :html
  """

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json], namespace: Web

      import Plug.Conn
      import Web.Gettext
      alias Web.Router.Helpers, as: Routes
    end
  end

  def html do
    quote do
      use Phoenix.Component
      use Phoenix.HTML

      import Web.VerifiedRoutes  # instead of use Phoenix.VerifiedRoutes directly

      import Web.Gettext
      import Web.CoreComponents
      alias Web.Router.Helpers, as: Routes
    end
  end


  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Web.Gettext
    end
  end

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
