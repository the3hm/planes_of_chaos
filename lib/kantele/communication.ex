defmodule Kantele.Communication do
  @moduledoc """
  Defines the initial communication channels available in the game.
  """

  use Kalevala.Communication

  @dialyzer {:nowarn_function, initial_channels: 0}
  @spec initial_channels() :: [{atom(), module(), list()}]
  def initial_channels do
    [
      {:general, Kantele.Communication.BroadcastChannel, []}
    ]
  end
end
