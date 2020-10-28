defmodule Shared.Ecto.MixProject do
  use Mix.Project

  def project do
    [
      app: :jehovakel_ex_ecto,
      version: "1.0.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_paths: ["lib"],
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      aliases: aliases(),
      name: "Jehovakel EX Ecto",
      source_url: "https://github.com/STUDITEMPS/jehovakel_ex/tree/master/jehovakel_ex_ecto",
      description: description(),
      package: package()
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
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.13"},
      {:timex, ">= 3.4.2"},
      {:excoveralls, ">= 0.10.5", only: :test},
      {:jason, ">= 0.0.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp description do
    "TODO: describe this package"
  end

  defp package do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "jehovakel_ex_ecto",
      # These are the default files included in the package
      licenses: ["MIT License"],
      links: %{
        "GitHub" => "https://github.com/STUDITEMPS/jehovakel_ex/tree/master/jehovakel_ex_ecto",
        "Studitemps" => "https://tech.studitemps.de"
      }
    ]
  end
end
