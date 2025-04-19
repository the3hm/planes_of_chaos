defmodule Web.ComponentHelpers do
  @moduledoc """
  Provides common setup for Phoenix Components, LiveViews, and LiveComponents.
  Includes Petal Components, helpers, Gettext, and verified routes.
  """

  defmacro __using__(_opts) do
    quote do
      # Core Phoenix setup
      use Phoenix.Component

      # Import Petal Components
      import Petal.Components
      alias Petal.Components, as: PC

      # Gettext
      import Web.Gettext

      # Verified Routes (Needs Web.Endpoint, Web.Router, Web.static_paths)
      # Placing this here should avoid circular dependency with Web itself.
      use Phoenix.VerifiedRoutes,
        endpoint: Web.Endpoint,
        router: Web.Router,
        statics: Web.static_paths()

      # Alias Routes for convenience
      alias Web.Router.Helpers, as: Routes
    end
  end
end
