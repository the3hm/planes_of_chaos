defmodule Web.Admin.RoomView do
  @moduledoc """
  Function components and helpers for rendering admin room management pages.
  """

  use Phoenix.Component

  import Web.VerifiedRoutes
  alias ExVenture.Rooms

  @doc """
  Returns the override value for a given field.

  It first checks assigns, falling back to the changeset field.
  """
  def override_value(assigns, field) do
    changeset = Map.get(assigns, :changeset)
    Map.get(assigns, field) || Ecto.Changeset.get_field(changeset, field)
  end

  @doc """
  Returns true if the room has a map icon.
  """
  def icon?(%Rooms.Room{map_icon: icon}), do: not is_nil(icon)
  def icon?(_), do: false
end
