defmodule Web.Admin.DashboardView do
  @moduledoc """
  View module for rendering the admin dashboard.
  """

  use Phoenix.Component
  use Phoenix.HTML

  import Web.VerifiedRoutes
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes
end
