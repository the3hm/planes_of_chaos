defmodule ExVenture.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_venture,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: {ExVenture.Application, []},
      extra_applications: [:logger, :runtime_tools, :phoenix_ecto, :ecto_sql, :postgrex, :petal_components]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies
  defp deps do
    [
      # Core Phoenix + HTML + LiveView
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8.6"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.0"},

      # UI & Styling
      {:tailwind, "~> 0.3.1"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.5",
       app: false,
       compile: false,
       sparse: "optimized"},
       {:petal_components, "~> 3.0"},

      # Storage & Uploads
      {:stein, "~> 0.5"},
      {:stein_storage, git: "https://github.com/smartlogic/stein_storage.git", branch: "main"},

      # Database & Ecto
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},

      # Mailer
      {:swoosh, "~> 1.18"},
      {:gen_smtp, "~> 1.2"},

      # Instrumentation
      {:telemetry, "~> 1.3"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},

      # HTTP / Server
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.7"},
      {:ranch, "~> 2.2", override: true},

      # Authentication
      {:argon2_elixir, "~> 3.0"},

      # Testing
      {:floki, ">= 0.30.0", only: :test},

      # Build Tools
      {:esbuild, "~> 0.7.0", runtime: Mix.env() == :dev},

      # Misc Utilities
      {:elias, "~> 0.2"},
      {:gettext, "~> 0.26.2"},
      {:jason, "~> 1.4"},
      {:logster, "~> 1.0"},
      {:porcelain, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:vapor, "~> 0.10.0"},

      # Kalevala MUD Engine
      {:kalevala, path: "../kalevala", override: true}, # Local fork with custom behavior tree + modular brains

      # Dev/Test Tools
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
