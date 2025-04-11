defmodule Web.EmailView do
  use Phoenix.View,
    root: "lib/ex_venture/emails/templates",
    namespace: Web

  use Phoenix.HTML
  import Web.Gettext
end
