defmodule Web.Admin.ZoneView do
  @moduledoc """
  View module for rendering admin zone management pages.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML

  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes

  alias Web.FormView
  alias Web.PaginationView
end
