defmodule Kantele.Character.WanderAction do
  @moduledoc """
  Action to pick a random exit and move.
  """

  use Kalevala.Character.Action

  import Kalevala.Character.Conn, only: [assign: 3, event: 2]

  @impl true
  def run(conn, _data) do
    conn
    |> event("room/wander")
    |> assign(:prompt, false)
  end

  def publish_error(conn, _error), do: conn
end
