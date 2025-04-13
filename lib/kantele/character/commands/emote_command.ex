defmodule Kantele.Character.EmoteCommand do
  @moduledoc """
  Parses and performs emotes as dynamic commands.
  """

  use Kalevala.Character.Command, dynamic: true

  alias Kantele.Character.Emotes
  alias Kantele.Character.EmoteAction
  alias Kantele.Character.EmoteView

  @impl true
  def parse(text, _opts) do
    case Emotes.get(text) do
      {:ok, command} ->
        {:dynamic, :broadcast, %{"text" => command.text}}

      {:error, :not_found} ->
        :skip
    end
  end

  # not a formal callback — no @impl here
  def broadcast(conn, params) do
    params = Map.put(params, "channel_name", "rooms:#{conn.character.room_id}")

    # Side effect only — returns :ok
    :ok = EmoteAction.run(conn, params)

    # Return conn manually
    assign(conn, :prompt, false)
  end

  # not a formal callback — no @impl here
  def list(conn, _params) do
    emotes = Enum.sort(Emotes.keys())
    render(conn, EmoteView, "list", %{emotes: emotes})
  end
end
