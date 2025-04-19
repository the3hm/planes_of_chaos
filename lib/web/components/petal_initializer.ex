defmodule Web.Components.PetalInitializer do
  @moduledoc """
  Handles initialization of Petal Components as a supervised process
  """
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    # Configure theme settings
    Application.put_env(:petal_components, :theme, %{
      app_name: "ExVenture",
      color_class_prefix: "dracula",
      dark_mode: true
    })

    {:ok, %{}}
  end
end
