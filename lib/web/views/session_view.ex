defmodule Web.SessionView do
  @moduledoc """
  Components and helpers for rendering the user session (login) pages.
  """

  use Phoenix.Component

  import Web.Gettext
  alias Web.Router.Helpers, as: Routes
  alias ExVenture.Config
end
