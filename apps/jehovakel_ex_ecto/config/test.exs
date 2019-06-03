use Mix.Config

{username, 0} = System.cmd("whoami", [])
username = username |> String.trim_trailing("\n")

config :jehovakel_ex_ecto, ecto_repos: [EctoTest.Repo]

config :jehovakel_ex_ecto, EctoTest.Repo,
  database: "jehovakel_ex_ecto_test",
  username: username,
  pool: Ecto.Adapters.SQL.Sandbox
