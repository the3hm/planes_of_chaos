defmodule Web.LayoutHelpers do
  @moduledoc false

  use Phoenix.Component

  @doc """
  Applies active tab CSS classes when the tab matches.
  """
  def tab_active?(current_tab, tab) when current_tab == tab do
    "bg-gray-900 text-white"
  end

  def tab_active?(_, _) do
    "text-gray-300 hover:bg-gray-700 hover:text-white"
  end

@doc """
Generates a static asset path using unverified_path.
"""
def static(path) when is_binary(path) do
  Phoenix.VerifiedRoutes.unverified_path(Web.Endpoint, Web.Router, path)
end

end
