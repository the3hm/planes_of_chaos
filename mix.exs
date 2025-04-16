defmodule ExVenture.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_venture,
      version: "0.1.0",
      elixir: "~> 1.18.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Docs
      name: "ExVenture",
      source_url: "https://github.com/the3hm/planes_of_chaos",
      homepage_url: "https://planesofchaos.net",
      docs: [
        main: "readme",
        logo: "assets/static/images/exventure.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExVenture.Application, []},
      extra_applications: [:iex, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Core Phoenix + HTML + LiveView
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8.6"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.0"},

      # UI & Styling
      {:backpex, "~> 0.12.0"},
      {:fluxon, "~> 1.0.10", repo: :fluxon},
      {:tailwind, "~> 0.3.1"},

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

      # Misc Utilities
      {:elias, "~> 0.2"},
      {:gettext, "~> 0.26.2"},
      {:jason, "~> 1.4"},
      {:logster, "~> 1.0"},
      {:porcelain, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:vapor, "~> 0.10.0"},

      # Kalevala MUD Engine
      {:kalevala, path: "../kalevala", override: true},

      # Dev/Test Tools
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end


  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.migrate.reset": ["ecto.drop", "ecto.create", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
