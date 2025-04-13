defmodule Web.Admin.RoomController do
  @moduledoc """
  Admin controller for managing rooms.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Rooms
  alias ExVenture.StagedChanges
  alias ExVenture.Zones

  plug Web.Plugs.ActiveTab, tab: :rooms
  plug Web.Plugs.FetchPage when action in [:index]

  @doc """
  Lists all rooms with pagination.
  """
  def index(conn, _params) do
    %{page: page, per: per} = conn.assigns
    %{page: rooms, pagination: pagination} = Rooms.all(page: page, per: per)

    conn
    |> assign(:rooms, rooms)
    |> assign(:pagination, pagination)
    |> assign(:path, ~p"/admin/rooms")
    |> render("index.html")
  end

  @doc """
  Displays a single room.
  """
  def show(conn, %{"id" => id}) do
    case Rooms.get(id) do
      {:ok, room} ->
        conn
        |> assign(:room, room)
        |> assign(:zone, room.zone)
        |> render("show.html")
    end
  end

  @doc """
  Renders form for creating a new room in a specific zone.
  """
  def new(conn, %{"zone_id" => zone_id}) do
    {:ok, zone} = Zones.get(zone_id)

    conn
    |> assign(:changeset, Rooms.new(zone))
    |> assign(:zone, zone)
    |> render("new.html")
  end

  @doc """
  Creates a room and redirects to the room show page.
  """
  def create(conn, %{"zone_id" => zone_id, "room" => params}) do
    {:ok, zone} = Zones.get(zone_id)

    case Rooms.create(zone, params) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room created!")
        |> redirect(to: ~p"/admin/rooms/#{room.id}")

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> assign(:zone, zone)
        |> put_status(:unprocessable_entity)
        |> put_flash(:error, "Could not save the room")
        |> render("new.html")
    end
  end

  @doc """
  Renders edit form for a room.
  """
  def edit(conn, %{"id" => id}) do
    case Rooms.get(id) do
      {:ok, room} ->
        conn
        |> assign(:changeset, Rooms.edit(room))
        |> assign(:room, room)
        |> assign(:zone, room.zone)
        |> render("edit.html")
    end
  end

  @doc """
  Updates a room and redirects to the show page.
  """
  def update(conn, %{"id" => id, "room" => params}) do
    {:ok, room} = Rooms.get(id)

    case Rooms.update(room, params) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room updated!")
        |> redirect(to: ~p"/admin/rooms/#{room.id}")

      {:error, changeset} ->
        conn
        |> assign(:room, room)
        |> assign(:changeset, changeset)
        |> assign(:zone, room.zone)
        |> put_status(:unprocessable_entity)
        |> put_flash(:error, "Could not save the room")
        |> render("edit.html")
    end
  end

  @doc """
  Publishes a staged room.
  """
  def publish(conn, %{"id" => id}) do
    {:ok, room} = Rooms.get(id)

    case Rooms.publish(room) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room published!")
        |> redirect(to: ~p"/admin/rooms/#{room.id}")
    end
  end

  @doc """
  Deletes all staged changes for a room.
  """
  def delete_changes(conn, %{"id" => id}) do
    {:ok, room} = Rooms.get(id)

    case StagedChanges.clear(room) do
      {:ok, room} ->
        redirect(conn, to: ~p"/admin/rooms/#{room.id}")
    end
  end
end
