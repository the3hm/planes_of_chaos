defmodule Web.Layouts do
  @moduledoc false

  use Phoenix.Component

  # 👇 This is the real fix that forces the macros in scope
  use Gettext, backend: Web.Gettext

  import Phoenix.LiveView.Helpers
  import Web.LayoutComponents

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  embed_templates "layouts/*"
end
