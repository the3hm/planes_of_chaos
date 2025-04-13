defmodule Web.Admin.StagedChangeController do
  @moduledoc """
  Admin interface for managing staged changes (view, delete, commit).
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.StagedChanges

  @doc """
  List all current staged changes.
  """
  def index(conn, _params) do
    conn
    |> assign(:active_tab, :staged_changes)
    |> assign(:staged_changes, StagedChanges.changes())
    |> render("index.html")
  end

  @doc """
  Delete a specific staged change.
  """
  def delete(conn, %{"id" => id, "type" => type}) do
    {:ok, staged_change} = StagedChanges.get(type, id)

    case StagedChanges.delete(staged_change) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Change deleted.")
        |> redirect(to: ~p"/admin/staged-changes")
    end
  end

  @doc """
  Commit all staged changes.
  """
  def commit(conn, _params) do
    case StagedChanges.commit() do
      :ok ->
        conn
        |> put_flash(:info, "Changes committed!")
        |> redirect(to: ~p"/admin/staged-changes")
    end
  end
end
