if Code.ensure_loaded?(Ecto) && Code.ensure_loaded?(Shared.Ecto.Term) do
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
      field(:event_type, :string)
      field(:data, Shared.Ecto.Term)
      field(:metadata, Shared.Ecto.Term)
      field(:created_at, :utc_datetime)
    end

    def migrate_event(event_type_to_migrate, migration, repository)
        when is_atom(event_type_to_migrate) and is_function(migration, 2) do
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
            {new_data, new_metadata} = migration.(event.data, event.metadata)
            %event_module{} = new_data
            event_type = Atom.to_string(event_module)

            changeset =
              change(event, event_type: event_type, data: new_data, metadata: new_metadata)

            Ecto.Multi.update(multi, event.event_id, changeset)
          end)

        repository.transaction(multi, timeout: 600_000_000)
      end
    after
      Ecto.Adapters.SQL.query!(
        repository,
        "CREATE RULE no_update_events AS ON UPDATE TO events DO INSTEAD NOTHING"
      )
    end
  end
end
