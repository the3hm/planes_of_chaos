defmodule Web.LayoutView do
  use Phoenix.Component
use Phoenix.HTML
import Web.Gettext
import Web.CoreComponents
alias Web.Router.Helpers, as: Routes

  import Web.Gettext, only: [gettext: 1]

  alias ExVenture.Users

  def admin?(user), do: Users.admin?(user)

  def tab_active?(tab, tab), do: "active"

  def tab_active?(_current_tab, _tab), do: ""
end
