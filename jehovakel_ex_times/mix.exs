defmodule JehovakelExTimes.MixProject do
  use Mix.Project

  def project do
    [
      app: :jehovakel_ex_times,
      version: "1.0.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_paths: ["lib"],
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      name: "Jehovakel EX Times",
      source_url: "https://github.com/STUDITEMPS/jehovakel_ex/tree/master/jehovakel_ex_times",
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
      {:timex, ">= 3.4.2"},
      {:excoveralls, ">= 0.10.5", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "TODO: describe this package"
  end

  defp package do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "jehovakel_ex_event_times",
      # These are the default files included in the package
      licenses: ["MIT License"],
      links: %{
        "GitHub" => "https://github.com/STUDITEMPS/jehovakel_ex/tree/master/jehovakel_ex_times",
        "Studitemps" => "https://tech.studitemps.de"
      }
    ]
  end
end
