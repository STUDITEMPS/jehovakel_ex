defmodule Shared.MixProject do
  use Mix.Project

  def project do
    [
      app: :jehovakel_ex_event_store,
      version: "0.1.0",
      build_path: "../../_build",
      deps_path: "../../deps",
      # config_path: "../../config/config.exs",
      # lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # CQRS event store using PostgreSQL for persistence
      {:eventstore, "~> 0.15"},
      {:ecto, "~> 3.0", optional: true},
      {:jehovakel_ex_ecto, ">= 0.0.0", optional: true, in_umbrella: true}
    ]
  end
end
