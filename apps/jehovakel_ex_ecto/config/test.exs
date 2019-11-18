use Mix.Config

config :jehovakel_ex_ecto, ecto_repos: [EctoTest.Repo]

config :jehovakel_ex_ecto, EctoTest.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER") || System.get_env()["USER"],
  password: System.get_env("PG_PASSWORD") || "",
  port: System.get_env("PG_PORT") || "5432",
  hostname: System.get_env("PG_HOST") || "localhost",
  database: System.get_env("PG_NAME") || "jehovakel_ex_ecto_#{Mix.env()}"
