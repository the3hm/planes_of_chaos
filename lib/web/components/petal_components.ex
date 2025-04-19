defmodule Web.Components.PetalComponents do
  @moduledoc """
  Initializes and configures Petal Components for use in the application.
  Configuration is called during application startup.
  """

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import Petal.Components
      alias Phoenix.LiveView.JS

      # Initialize configuration
      require Petal.Components
    end
  end

  @doc """
  Apply configuration for Petal Components.
  This should be called during application startup.
  """
  def init do
    Application.put_env(:petal_components, :theme, %{
      app_name: "ExVenture",
      color_class_prefix: "dracula",
      dark_mode: true
    })
  end
end
