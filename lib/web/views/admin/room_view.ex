defmodule Web.Admin.RoomView do
  @moduledoc """
  View module for rendering admin room management pages.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML

  import Web.Gettext
  import Web.VerifiedRoutes
  import Web.CoreComponents

  alias Web.Router.Helpers, as: Routes
  alias Web.FormView
  alias Web.PaginationView

  alias ExVenture.Rooms

  @doc "Returns the value of a field from assigns or the changeset fallback"
  def override_value(assigns, field) do
    changeset = Map.get(assigns, :changeset)
    Map.get(assigns, field) || Ecto.Changeset.get_field(changeset, field)
  end

  @doc "Checks if a room has a map icon set"
  def icon?(room), do: not is_nil(room.map_icon)
end
