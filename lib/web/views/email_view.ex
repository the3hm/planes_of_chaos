defmodule Web.EmailView do
  @moduledoc """
  Renders email templates for transactional messages.
  """

  use Phoenix.Template,
    root: "lib/web/templates/email",
    pattern: "**/*"

  import Phoenix.HTML
  import Web.Gettext
end
