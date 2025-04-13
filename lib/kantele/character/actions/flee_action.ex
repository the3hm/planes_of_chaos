defmodule Kantele.Character.FleeAction do
  @moduledoc """
  Action to flee to a random exit in a room.
  """

  use Kalevala.Character.Action, as: Action

  require Kalevala.Character.Conn
  alias Kalevala.Character.Conn

  @impl true
  def run(conn, _params) do
    conn
    |> Conn.event("room/flee")
    |> Conn.assign(:prompt, false)

    :ok
  end

  def publish_error(conn, _error), do: conn
end
