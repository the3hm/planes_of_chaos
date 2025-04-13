defmodule Kantele.Character.WanderAction do
  @moduledoc """
  Action to pick a random exit and move.
  """

  use Kalevala.Character.Action

  @impl true
  def run(conn, _data) do
    _conn =
      conn
      |> event("room/wander")
      |> assign(:prompt, false)

    :ok
  end

  def publish_error(conn, _error), do: conn
end
