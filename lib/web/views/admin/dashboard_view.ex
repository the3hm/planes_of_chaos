defmodule Web.Admin.DashboardView do
  @moduledoc """
  View module for rendering the admin dashboard.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML

  import Web.Gettext
  import Web.VerifiedRoutes
  import Web.CoreComponents

  alias Web.Router.Helpers, as: Routes
end
