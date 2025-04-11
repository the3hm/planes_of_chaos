defmodule Web.VerifiedRoutes do
  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()
end
