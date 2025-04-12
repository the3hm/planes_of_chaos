defmodule Web do
  @moduledoc """
  Entrypoint for defining your web interface (controllers, components, channels).

  Example usage:

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

      # Phoenix.VerifiedRoutes provides path helpers as functions
      import Web.VerifiedRoutes

      import Web.Gettext
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
  Use with: `use Web, :controller`, `use Web, :html`, etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
