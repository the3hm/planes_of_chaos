defmodule Web.PageView do
  @moduledoc """
  View helpers for the main site pages.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes

  alias Web.ReactView

  @doc "Signs and returns character data for the frontend client"
  def characters_for_client(characters) do
    Enum.map(characters, fn character ->
      %{
        name: character.name,
        token: Phoenix.Token.sign(Web.Endpoint, "character id", character.id)
      }
    end)
  end
end
