defmodule Web.Admin.UserView do
  @moduledoc """
  View module for rendering user admin pages.
  """

  use Phoenix.Component
  use Phoenix.HTML

  import Web.VerifiedRoutes
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes
end
