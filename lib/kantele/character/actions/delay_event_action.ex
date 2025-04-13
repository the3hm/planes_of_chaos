defmodule Kantele.Character.DelayEventAction do
  @moduledoc """
  Action to delay sending an event by a randomized amount of time.

  Expects parameters:
    - "minimum_delay" (integer, default 0)
    - "random_delay" (integer, default 0)
    - "topic" (string, required)
    - "data" (map of string keys, optional)
  """

  use Kalevala.Character.Action

  # Macros require explicit `require` to use them
  require Kalevala.Character.Conn

  @impl true
  def run(conn, params) do
    delay = build_delay(params)
    topic = fetch_topic!(params)
    data = symbolize_keys(Map.get(params, "data", %{}))

    # Wrap macro call in parentheses to avoid ambiguity
    (Kalevala.Character.Conn.delay_event(conn, delay, topic, data))
  end

  defp build_delay(%{"minimum_delay" => min, "random_delay" => max})
       when is_integer(min) and is_integer(max) and max >= 0 do
    min + Enum.random(0..max)
  end

  defp build_delay(%{"random_delay" => max}) when is_integer(max) and max >= 0 do
    Enum.random(0..max)
  end

  defp build_delay(_params), do: 0

  defp fetch_topic!(%{"topic" => topic}) when is_binary(topic), do: topic

  defp fetch_topic!(_),
    do: raise(ArgumentError, "expected a \"topic\" parameter")

  defp symbolize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
