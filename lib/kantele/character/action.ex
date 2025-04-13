defmodule Kalevala.Character.Action do
  @moduledoc """
  Behaviour definition for character actions.

  Actions define game behaviors characters can trigger via events,
  typically by returning an updated `%Kalevala.Character.Conn{}` struct.
  """

  alias Kalevala.Character.Conn

  @typedoc "Parameters passed to an action module."
  @type params :: map()

  @typedoc "The connection struct passed to and returned from actions."
  @type conn :: Conn.t()

  @callback run(conn, params) :: conn

  @doc """
  Publishes a message with optional metadata and error handler.
  """
  defmacro publish_message(conn, channel, text, opts, _error_handler) do
    quote do
      event_data = %{
        channel: unquote(channel),
        text: unquote(text),
        opts: unquote(opts)
      }

      new_events = unquote(conn).events ++ [%{topic: "message/publish", data: event_data}]
      %{unquote(conn) | events: new_events}
    end
  end

end
