defmodule Web.Layouts do
  @moduledoc false

  use Web, :html


  import Web.LayoutComponents

  embed_templates "layouts/*"
end
