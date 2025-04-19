defmodule ExVenture.Zones.ZoneSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "zones" do
    field :key, :string
    field :name, :string
    field :description, :string

    timestamps()
  end

  def changeset(zone, attrs) do
    zone
    |> cast(attrs, [:key, :name, :description])
    |> validate_required([:key, :name])
    |> unique_constraint(:key)
  end
end
