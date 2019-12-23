defmodule Shared.EventTest do
  use ExUnit.Case
  @moduletag :integration

  @event %Shared.EventTest.FakeEvent{}
  @metadata %{meta: "data"}

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

  test "append event to stream" do
    assert {:ok, [%{data: @event}]} = JehovakelEx.EventStore.append_event(@event, @metadata)

    assert [%EventStore.RecordedEvent{data: @event, metadata: @metadata}] =
             JehovakelEx.EventStore.all_events(nil, unwrap: false)

    assert [{@event, @metadata}] = JehovakelEx.EventStore.all_events()
  end

  test "append event to stream with stream_uuid" do
    assert {:ok, [%{data: @event}]} =
             JehovakelEx.EventStore.append_event("stream_uuid", @event, @metadata)

    assert [%EventStore.RecordedEvent{data: @event, metadata: @metadata}] =
             JehovakelEx.EventStore.all_events(nil, unwrap: false)

    assert [{@event, @metadata}] = JehovakelEx.EventStore.all_events()
    assert [{@event, @metadata}] = JehovakelEx.EventStore.all_events("stream_uuid")
  end

  test "append list of events" do
    assert {:ok, [%{data: @event}]} = JehovakelEx.EventStore.append_event([@event], @metadata)

    assert [%EventStore.RecordedEvent{data: @event, metadata: @metadata}] =
             JehovakelEx.EventStore.all_events(nil, unwrap: false)

    assert [{@event, @metadata}] = JehovakelEx.EventStore.all_events()
  end
end
