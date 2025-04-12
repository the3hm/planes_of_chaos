defmodule Web.RegistrationResetView do
  @moduledoc """
  Handles rendering for password/registration reset flows.
  """

  use Phoenix.Component

  import Web.Gettext
  import Web.VerifiedRoutes
  alias Web.Router.Helpers, as: Routes
end
