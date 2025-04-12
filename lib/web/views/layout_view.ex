defmodule Web.LayoutView do
  @moduledoc """
  View helpers for layout rendering and tab handling.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes

  alias ExVenture.Users

  @doc "Returns true if the user is an admin"
  def admin?(user), do: Users.admin?(user)

  @doc "Sets active tab class"
  def tab_active?(tab, tab), do: "active"
  def tab_active?(_current_tab, _tab), do: ""
end
