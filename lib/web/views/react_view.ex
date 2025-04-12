defmodule Web.ReactView do
  @moduledoc """
  View helper for embedding React components via server-side rendered divs.

  Generates divs with data attributes that client-side React code can hydrate.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes

  @doc """
  Renders a div with `data-react-class` and `data-react-props` attributes
  for client-side hydration of a React component.

  ## Examples

      <%= react_component("UserProfile", %{user_id: 1}) %>
  """
  def react_component(name, props, opts \\ []) do
    props = Jason.encode!(Map.new(props))
    data = Keyword.get(opts, :data, [])
    data = Keyword.merge(data, react_class: name, react_props: props)

    opts = Keyword.put(opts, :data, data)

    content_tag(:div, "", opts)
  end
end
