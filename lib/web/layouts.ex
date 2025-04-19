defmodule Web.Layouts do
  @moduledoc false

  use Phoenix.Component
  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  use Gettext, backend: Web.Gettext

  # Phoenix imports
  import Phoenix.Component
  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.VerifiedRoutes, only: [sigil_p: 2]

  # Core Components
  import Web.CoreComponents
  import Web.LayoutComponents
  import Web.ComponentHelpers

  # Security
  import Plug.CSRFProtection, only: [get_csrf_token: 0]

  alias Web.Router.Helpers, as: Routes

  embed_templates "layouts/*"

  # If controllers need layouts, they might need specific imports here,
  # but let's keep it minimal for now.
end
