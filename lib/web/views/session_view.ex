defmodule Web.SessionView do
  @moduledoc """
  Handles rendering for user login/session pages.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes

  alias ExVenture.Config
end
