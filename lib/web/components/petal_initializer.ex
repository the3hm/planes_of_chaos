defmodule Web.Components.PetalInitializer do
  @moduledoc """
  Handles initialization of Petal Components
  """

  def init do
    # Configure theme settings
    Application.put_env(:petal_components, :theme, %{
      app_name: "ExVenture",
      color_class_prefix: "dracula",
      dark_mode: true
    })

    # Ensure Petal Components is loaded
    case Application.ensure_all_started(:petal_components) do
      {:ok, _} -> :ok
      {:error, _} = error -> error
    end
  end
end
