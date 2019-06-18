defmodule JehovakelExTimes.MixProject do
  use Mix.Project

  def project do
    [
      app: :jehovakel_ex_times,
      version: "0.1.0",
      build_path: "_build",
      deps_path: "deps",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:timex, ">= 3.4.2"},
      {:excoveralls, ">= 0.10.5", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
