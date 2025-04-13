defmodule Kantele.Communication.BroadcastChannel do
  @moduledoc """
  Broadcast channel for the 'general' communication line.

  This channel receives messages and rebroadcasts them to all subscribed users.
  """

  use Kalevala.Communication.Channel

  # This is not a declared @callback, so do NOT annotate with @impl
  def receive(_event, message, state) do
    {:broadcast, message, state}
  end
end
