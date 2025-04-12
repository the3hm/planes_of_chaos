defmodule Web.RegistrationView do
  @moduledoc """
  Handles rendering for user registration pages.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes
end
