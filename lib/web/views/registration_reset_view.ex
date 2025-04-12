defmodule Web.RegistrationResetView do
  @moduledoc """
  Handles rendering for password/registration reset flows.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes
end
