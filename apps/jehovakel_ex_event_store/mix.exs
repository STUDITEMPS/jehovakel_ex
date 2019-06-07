defmodule Shared.MixProject do
  use Mix.Project

  def project do
    [
      app: :jehovakel_ex_event_store,
      version: "0.1.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_path: "_build",
      deps_path: "deps",
      # config_path: "../../config/config.exs",
      # lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      test_paths: ["test", "lib"],
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # CQRS event store using PostgreSQL for persistence
      {:eventstore, "~> 0.15"},
      {:ecto, "~> 3.0", optional: true},
      {:ecto_sql, "~> 3.0", optional: true},
      {:jehovakel_ex_ecto, ">= 0.0.0", optional: true, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "event_store.init", "ecto.migrate", "test"]
    ]
  end
end
