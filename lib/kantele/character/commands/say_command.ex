defmodule Kantele.Character.SayCommand do
  @moduledoc """
  Command for saying something out loud, either generally or at someone.
  """

  use Kalevala.Character.Command

  alias Kantele.Character.SayAction

  def run(conn, %{"at" => _at} = params) do
    conn
    |> event("say/send", params)
    |> assign(:prompt, false)
  end

  def run(conn, params) do
    params = Map.put(params, "channel_name", "rooms:#{conn.character.room_id}")

    # Execute the say action side-effect
    :ok = SayAction.run(conn, params)

    # Return the original conn with prompt suppressed
    assign(conn, :prompt, false)
  end
end
