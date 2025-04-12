defmodule Web.Components.CoreComponentsBase do
  @moduledoc """
  Base implementation of core Phoenix components.
  """

  use Phoenix.Component
  use Phoenix.HTML

  import Web.Gettext
  alias Phoenix.LiveView.JS
end
