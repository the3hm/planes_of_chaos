defmodule Web.API.StagedChangeView do
  @moduledoc """
  Renders JSON responses for staged change API endpoints.
  """

  @doc """
  Renders a list of staged changes.
  """
  def render("index.json", %{staged_changes: staged_changes}) do
    %{
      items: Enum.map(staged_changes, &render("show.json", %{staged_change: &1})),
      links: []
    }
  end

  def render("show.json", %{staged_change: staged_change}) do
    %{
      attribute: staged_change.attribute,
      value: staged_change.value,
      links: []
    }
  end
end
