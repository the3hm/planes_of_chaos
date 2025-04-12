defmodule Web.Admin.UserView do
  @moduledoc """
  View module for rendering user admin pages.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML

  import Web.Gettext
  import Web.VerifiedRoutes
  import Web.CoreComponents

  alias Web.Router.Helpers, as: Routes
end
