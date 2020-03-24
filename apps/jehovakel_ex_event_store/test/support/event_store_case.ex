defmodule Support.EventStoreCase do
  @moduledoc """
  Used for Tests using event store
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import JehovakelEx.EventStore,
        only: [append_event: 2, append_event: 3, all_events: 2, all_events: 1, all_events: 0],
        warn: false
    end
  end

  setup _tags do
    # reset eventstore
    config = EventStore.Config.parsed(JehovakelEx.EventStore, :jehovakel_ex_event_store)
    postgrex_config = EventStore.Config.default_postgrex_opts(config)
    {:ok, eventstore_connection} = Postgrex.start_link(postgrex_config)
    EventStore.Storage.Initializer.reset!(eventstore_connection)
    {:ok, _} = Application.ensure_all_started(:eventstore)

    start_supervised!(JehovakelEx.EventStore)

    on_exit(fn ->
      # stop eventstore application
      Application.stop(:eventstore)
      Process.exit(eventstore_connection, :shutdown)
    end)

    :ok
  end
end
