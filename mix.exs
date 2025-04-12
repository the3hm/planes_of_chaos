defmodule ExVenture.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_venture,
      version: "0.1.0",
      elixir: "~> 1.18.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Docs
      name: "ExVenture",
      source_url: "https://github.com/oestrich/ex_venture",
      homepage_url: "https://exventure.org",
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
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.6"},
      {:swoosh, "~> 1.18"},
      # For SMTP delivery (optional, use Sendgrid/Postmark if you prefer)
      {:gen_smtp, "~> 1.2"},
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:ecto_sql, "~> 3.12"},
      {:elias, "~> 0.2"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:ranch, "~> 2.2", override: true},
      {:kalevala, git: "https://github.com/the3hm/kalevala.git", branch: "main", override: true},
      {:logster, "~> 1.0"},
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.6"},
      {:porcelain, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:stein, "~> 0.5"},
      {:stein_storage, git: "https://github.com/smartlogic/stein_storage.git", branch: "main"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:vapor, "~> 0.10.0"}
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
