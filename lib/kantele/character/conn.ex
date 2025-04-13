defmodule Kalevala.Character.Conn do
  @moduledoc """
  Struct for character connection, passed into action modules.

  Also provides helper macros to assign data, fire events, and render views.
  """

  defstruct [
    :character,
    :room,
    :socket,
    assigns: %{},
    events: []
  ]

  @type t :: %__MODULE__{
          character: any(),
          room: any(),
          socket: any(),
          assigns: map(),
          events: list()
        }

  @doc """
  Assigns a value to the connection.
  """
  defmacro assign(conn, key, value) do
    quote do
      %{unquote(conn) | assigns: Map.put(unquote(conn).assigns, unquote(key), unquote(value))}
    end
  end

  @doc """
  Appends an event to the connection.
  """
  defmacro event(conn, topic) do
    quote do
      %{unquote(conn) | events: unquote(conn).events ++ [%{topic: unquote(topic)}]}
    end
  end

  @doc """
  Renders a view into the connection assigns.
  """
  defmacro render(conn, view_module, template) do
    quote do
      html = apply(unquote(view_module), :render, [unquote(template), unquote(conn)])
      %{unquote(conn) | assigns: Map.put(unquote(conn).assigns, :rendered, html)}
    end
  end

  @doc """
  Schedules a delayed event to be handled later.
  """
  defmacro delay_event(conn, delay, topic, data) do
    quote do
      event = %{
        delay: unquote(delay),
        topic: unquote(topic),
        data: unquote(data)
      }

      %{unquote(conn) | events: unquote(conn).events ++ [event]}
    end
  end
end
