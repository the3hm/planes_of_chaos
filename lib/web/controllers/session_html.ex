defmodule Web.SessionHTML do
  use Web, :html

  import Web.CoreComponents

  embed_templates "session_html/*"
end
