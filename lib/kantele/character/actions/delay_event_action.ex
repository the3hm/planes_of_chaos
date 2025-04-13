defmodule Kantele.Character.DelayEventAction do
  @moduledoc """
  Delay an event by a specified duration with optional randomness.
  """

  use Kalevala.Character.Action

  @impl true
  def run(conn, params) do
    minimum_delay = Map.get(params, "minimum_delay", 0)
    random_delay = Map.get(params, "random_delay", 0)
    delay = minimum_delay + Enum.random(0..random_delay)

    data =
      params
      |> Map.get("data", %{})
      |> Enum.into(%{}, fn {key, value} ->
        {String.to_atom(key), value}
      end)

    # Delay the event, but discard the returned conn
    _conn = delay_event(conn, delay, params["topic"], data)

    # Return :ok to comply with Kalevala.Action behavior
    :ok
  end
end
