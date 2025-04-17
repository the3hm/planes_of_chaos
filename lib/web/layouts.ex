defmodule Web.Layouts do
  @moduledoc false

  use Web, :html

  import Web.Gettext         # <- Ensures gettext/1 is seen by .heex compiler
  import Phoenix.VerifiedRoutes
  import Web.LayoutComponents

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  embed_templates "layouts/*"
end
