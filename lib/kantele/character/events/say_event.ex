defmodule Kantele.Character.SayEvent do
  @moduledoc """
  Handles events related to character speech.
  """

  use Kalevala.Character.Event

  alias Kantele.Character.CommandView
  alias Kantele.Character.SayAction
  alias Kantele.Character.SayView

  def interested?(event) do
    event.data.type == "speech" && match?("rooms:" <> _, event.data.channel_name)
  end

  def broadcast(conn, %{data: %{"at" => at, "at_character" => nil}}) do
    conn
    |> assign(:name, at)
    |> render(SayView, "character-not-found")
    |> prompt(CommandView, "prompt", %{})
  end

  def broadcast(conn, event) do
    params = Map.put(event.data, "channel_name", "rooms:#{conn.character.room_id}")

    # Perform side effect (SayAction), discard return
    :ok = SayAction.run(conn, params)

    # Return original conn with prompt turned off
    assign(conn, :prompt, false)
  end

  def echo(conn, event) do
    conn
    |> assign(:character, event.data.character)
    |> assign(:id, event.data.id)
    |> assign(:text, event.data.text)
    |> assign(:meta, event.data.meta)
    |> render(SayView, say_view(event))
    |> prompt(CommandView, "prompt", %{})
  end

  defp say_view(event) do
    if event.from_pid == self() do
      "echo"
    else
      "listen"
    end
  end

  def publish_error(conn, _error), do: conn
end
