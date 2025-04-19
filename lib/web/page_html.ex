defmodule Web.PageHTML do
  @moduledoc """
  HTML templates for PageController.
  """

  use Web, :html

  embed_templates "page_html/*"

  # Add this helper so your template compiles
  defp characters_for_client(characters) do
    Enum.map(characters, fn character ->
      %{
        id: character.id,
        name: character.name
        # Add other fields as needed for your React client
      }
    end)
  end
end
