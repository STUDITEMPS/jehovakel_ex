defmodule Shared.Ecto.MixProject do
  use Mix.Project

  def project do
    [
      app: :jehovakel_ex_ecto,
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
      {:ecto, "~> 2.2 or ~> 3.0"},
      {:postgrex, "~> 0.13"},
      {:timex, ">= 3.4.2"},
      {:excoveralls, ">= 0.10.5", only: :test}
    ]
  end
end
