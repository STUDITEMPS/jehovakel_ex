if Code.ensure_loaded?(Ecto) do
  defmodule Shared.EventStore.Migration.Event do
    @moduledoc """
    Warnung: Diese Datei ist ungetestet. Vergewissere dich, dass du deine Skripte, die darauf basieren gut lokal und
    auf Staging getestet sind, bevor du diese auf Production loslässt!!!
    """
    use Ecto.Schema
    import Ecto.Query
    import Ecto.Changeset
    require Logger

    @primary_key {:event_id, :binary_id, autogenerate: false}
    schema "events" do
      field(:data, Shared.Ecto.Term)
      field(:event_type, :string)
    end

    def migrate_event(event_type_to_migrate, migration, repository \\ Arbeitsentgelt.Repo)
        when is_atom(event_type_to_migrate) and is_function(migration, 1) do
      event_type = Atom.to_string(event_type_to_migrate)

      events =
        from(
          e in Shared.EventStore.Migration.Event,
          where: e.event_type == ^event_type
        )
        |> repository.all()

      if Enum.any?(events) do
        Logger.info(
          "Migrating " <>
            to_string(Enum.count(events)) <>
            " Events vom Typ " <> to_string(event_type_to_migrate)
        )

        Ecto.Adapters.SQL.query!(repository, "DROP RULE no_update_events ON events")

        multi =
          Enum.reduce(events, Ecto.Multi.new(), fn event, multi ->
            new_data = migration.(event.data)
            changeset = change(event, data: new_data)
            Ecto.Multi.update(multi, event.event_id, changeset)
          end)

        repository.transaction(multi)

        Ecto.Adapters.SQL.query!(
          repository,
          "CREATE RULE no_update_events AS ON UPDATE TO events DO INSTEAD NOTHING"
        )
      end
    end
  end
end
