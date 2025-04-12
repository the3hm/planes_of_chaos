defmodule Web.EmailView do
  @moduledoc """
  Renders email templates for transactional messages.
  """

  use Phoenix.View,
    root: "lib/ex_venture/emails/templates",
    namespace: Web

  use Phoenix.HTML
  import Web.Gettext
end
