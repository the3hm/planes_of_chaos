defmodule Web.PageView do
  @moduledoc """
  Page-level helpers for rendering public pages.
  """

  use Phoenix.Component

  import Web.Gettext
  alias Web.ReactView
  alias Web.Router.Helpers, as: Routes

  @doc """
  Signs and returns character data for the frontend client.

  ## Example

      [
        %{name: "Ahsoka", token: "..."},
        %{name: "Thrawn", token: "..."}
      ]
  """
  def characters_for_client(characters) do
    Enum.map(characters, fn character ->
      %{
        name: character.name,
        token: Phoenix.Token.sign(Web.Endpoint, "character id", character.id)
      }
    end)
  end
end
