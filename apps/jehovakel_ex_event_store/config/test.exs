use Mix.Config

config :ecto, :json_library, Jason

config :jehovakel_ex_event_store,
  ecto_repos: [Support.Repo]

# General Repository configuration
config :jehovakel_ex_event_store, Support.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER") || System.get_env()["USER"],
  password: System.get_env("PG_PASSWORD") || "",
  port: System.get_env("PG_PORT") || "5432",
  hostname: System.get_env("PG_HOST") || "localhost",
  database: System.get_env("PG_NAME") || "jehovakel_ex_#{Mix.env()}",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  # Avoid collisions with eventstore `schema_migrations` relation
  migration_source: "readstore_schema_migrations"

config :eventstore, EventStore.Storage,
  serializer: EventStore.TermSerializer,
  username: System.get_env("PG_USER") || System.get_env()["USER"],
  password: System.get_env("PG_PASSWORD") || "",
  port: System.get_env("PG_PORT") || "5432",
  hostname: System.get_env("PG_HOST") || "localhost",
  database: System.get_env("PG_NAME") || "jehovakel_ex_#{Mix.env()}",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
