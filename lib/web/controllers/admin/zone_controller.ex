defmodule Web.Admin.ZoneController do
  @moduledoc """
  Admin controller for managing zones.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Zones
  alias ExVenture.StagedChanges

  plug Web.Plugs.ActiveTab, tab: :zones
  plug Web.Plugs.FetchPage when action in [:index]

  @doc """
  Lists paginated zones.
  """
  def index(conn, _params) do
    %{page: page, per: per} = conn.assigns
    %{page: zones, pagination: pagination} = Zones.all(page: page, per: per)

    conn
    |> assign(:zones, zones)
    |> assign(:pagination, pagination)
    |> assign(:path, ~p"/admin/zones")
    |> render("index.html")
  end

  @doc """
  Shows a single zone.
  """
  def show(conn, %{"id" => id}) do
    case Zones.get(id) do
      {:ok, zone} ->
        conn
        |> assign(:zone, zone)
        |> assign(:mini_map, Zones.make_mini_map(zone))
        |> render("show.html")
    end
  end

  @doc """
  Renders the new zone form.
  """
  def new(conn, _params) do
    conn
    |> assign(:changeset, Zones.new())
    |> render("new.html")
  end

  @doc """
  Creates a new zone and redirects.
  """
  def create(conn, %{"zone" => params}) do
    case Zones.create(params) do
      {:ok, zone} ->
        conn
        |> put_flash(:info, "Zone created!")
        |> redirect(to: ~p"/admin/zones/#{zone.id}")

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_flash(:error, "Could not save the zone")
        |> render("new.html")
    end
  end

  @doc """
  Renders the edit zone form.
  """
  def edit(conn, %{"id" => id}) do
    case Zones.get(id) do
      {:ok, zone} ->
        conn
        |> assign(:zone, zone)
        |> assign(:changeset, Zones.edit(zone))
        |> render("edit.html")
    end
  end

  @doc """
  Updates a zone and redirects.
  """
  def update(conn, %{"id" => id, "zone" => params}) do
    {:ok, zone} = Zones.get(id)

    case Zones.update(zone, params) do
      {:ok, zone} ->
        conn
        |> put_flash(:info, "Zone updated!")
        |> redirect(to: ~p"/admin/zones/#{zone.id}")

      {:error, changeset} ->
        conn
        |> assign(:zone, zone)
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_flash(:error, "Could not save the zone")
        |> render("edit.html")
    end
  end

  @doc """
  Publishes a zone.
  """
  def publish(conn, %{"id" => id}) do
    {:ok, zone} = Zones.get(id)

    case Zones.publish(zone) do
      {:ok, zone} ->
        conn
        |> put_flash(:info, "Zone Published!")
        |> redirect(to: ~p"/admin/zones/#{zone.id}")
    end
  end

  @doc """
  Deletes all staged changes for a zone.
  """
  def delete_changes(conn, %{"id" => id}) do
    {:ok, zone} = Zones.get(id)

    case StagedChanges.clear(zone) do
      {:ok, zone} ->
        redirect(conn, to: ~p"/admin/zones/#{zone.id}")
    end
  end
end
