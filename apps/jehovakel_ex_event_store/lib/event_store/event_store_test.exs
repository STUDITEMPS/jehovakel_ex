defmodule Shared.EventTest.FailingEventStoreBackend do
  def append_to_stream(_stream_uuid, :any_version, _events) do
    {:error, "something bad happend"}
  end
end

defmodule Shared.EventTest do
  use ExUnit.Case
  # use Support.DataCase
  @moduletag :integration
  alias Shared.EventTest.FailingEventStoreBackend

  @event %Shared.EventTest.FakeEvent{}
  @metadata %{meta: "data"}

  setup _tags do
    # reset eventstore
    config = EventStore.Config.parsed()
    postgrex_config = EventStore.Config.default_postgrex_opts(config)
    {:ok, eventstore_connection} = Postgrex.start_link(postgrex_config)
    EventStore.Storage.Initializer.reset!(eventstore_connection)
    {:ok, _} = Application.ensure_all_started(:eventstore)

    on_exit(fn ->
      # stop eventstore application
      Application.stop(:eventstore)
      Process.exit(eventstore_connection, :shutdown)
    end)

    :ok
  end

  test "append event to stream" do
    assert {:ok, [%{data: @event}]} = Shared.EventStore.append_event(@event, @metadata)

    assert [%EventStore.RecordedEvent{data: @event, metadata: @metadata}] =
             Shared.EventStore.all_events(nil, unwrap: false)

    assert [{@event, @metadata}] = Shared.EventStore.all_events()
  end

  test "returns error tuple if save fails" do
    assert {:error, "something bad happend"} =
             Shared.EventStore.append_event(@event, @metadata, FailingEventStoreBackend)
  end

  test "logs event on appending to event store" do
    # Impossible to test as the :warn log level defined in test.exs removes all
    # log function calls from the compiled code.

    # assert ExUnit.CaptureLog.capture_log(fn ->
    #          EventStore.append_event(@event, @metadata)
    #        end) =~ "FakeEvent: logging"
  end
end
