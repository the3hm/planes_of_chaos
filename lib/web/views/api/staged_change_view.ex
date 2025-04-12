defmodule Web.API.StagedChangeView do
  @moduledoc """
  Renders JSON responses for staged change API endpoints.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes

  @doc "Renders a list of staged changes"
  def render("index.json", %{staged_changes: staged_changes}) do
    %{
      items: render_many(staged_changes, __MODULE__, "show.json"),
      links: []
    }
  end

  @doc "Renders a single staged change"
  def render("show.json", %{staged_change: staged_change}) do
    %{
      attribute: staged_change.attribute,
      value: staged_change.value,
      links: []
    }
  end
end
