defmodule Web.Admin.ZoneView do
  @moduledoc """
  Component helpers for rendering admin zone management pages.
  """

  use Phoenix.Component

  import Web.Gettext
  alias Web.Router.Helpers, as: Routes

  alias Web.FormView
  alias Web.PaginationView
end
