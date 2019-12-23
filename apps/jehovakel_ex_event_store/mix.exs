defmodule Shared.MixProject do
  use Mix.Project

  def project do
    [
      app: :jehovakel_ex_event_store,
      version: "0.2.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_path: "_build",
      deps_path: "deps",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      test_paths: ["test", "lib"],
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: ["ecto.create --quiet", "event_store.init", "ecto.migrate", "test"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # CQRS event store using PostgreSQL for persistence
      {:eventstore, "~> 1.0"},
      {:ecto, "~> 3.0", optional: true},
      {:ecto_sql, "~> 3.0", optional: true},
      {:jehovakel_ex_ecto, ">= 0.0.0", optional: true, in_umbrella: true},
      {:excoveralls, ">= 0.10.5", only: :test}
    ]
  end
end
