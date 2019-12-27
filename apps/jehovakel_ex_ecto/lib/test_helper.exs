Application.ensure_all_started(:postgrex)
Application.ensure_all_started(:ecto)
JehovakelExEcto.Repo.start_link()

ExUnit.start(capture_log: true)

Ecto.Adapters.SQL.Sandbox.mode(JehovakelExEcto.Repo, :manual)
