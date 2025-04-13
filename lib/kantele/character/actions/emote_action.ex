defmodule Kantele.Character.EmoteAction do
  @moduledoc """
  Action to emote in a channel (e.g. a room).
  """


  # Require Conn so we can use its macros
  require Kalevala.Character.Conn
  alias Kalevala.Character.Conn

  # Require Action for publish_message macro
  require Kalevala.Character.Action
  alias Kalevala.Character.Action

  alias Kantele.Character.EmoteView

  @impl true
  def run(conn, params) do
    conn
    |> Conn.assign(:text, params["text"])
    |> Conn.render(EmoteView, "echo")
    |> Action.publish_message(%{
      channel_name: params["channel_name"],
      text: params["text"],
      metadata: [type: "emote"]
    }, &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end
