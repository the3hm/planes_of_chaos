defmodule Web.ReactView do
  @moduledoc """
  View helper for embedding React components via server-side rendered divs.

  Generates divs with `data-react-class` and `data-react-props` attributes
  that client-side React code can hydrate.
  """

  use Phoenix.Component

  import Phoenix.Component

  @doc """
  Renders a div with `data-react-class` and `data-react-props` attributes.

  ## Example

      <.react_component name="UserProfile" props={%{user_id: 1}} />
  """
  attr :name, :string, required: true
  attr :props, :map, required: true
  attr :rest, :global, default: %{}

  def react_component(assigns) do
    ~H"""
    <div
      data-react-class={@name}
      data-react-props={Jason.encode!(@props)}
      {@rest}
    />
    """
  end
end
