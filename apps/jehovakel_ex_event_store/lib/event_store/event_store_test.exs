defmodule Shared.EventTest.FailingEventStoreBackend do
  def append_to_stream(_stream_uuid, :any_version, _events) do
    {:error, "something bad happend"}
  end
end

defmodule Shared.EventTest do
  use Support.DataCase
  @moduletag :integration
  alias Shared.EventTest.FailingEventStoreBackend
  alias Shared.EventStore

  @event %Shared.EventTest.FakeEvent{}
  @metadata %{meta: "data"}

  test "append event to stream" do
    assert {:ok, [%{data: @event}]} = EventStore.append_event(@event, @metadata)
    assert [%{data: @event}] = EventStore.all_events()
  end

  test "returns error tuple if save fails" do
    assert {:error, "something bad happend"} =
             EventStore.append_event(@event, @metadata, FailingEventStoreBackend)
  end

  test "logs event on appending to event store" do
    # Impossible to test as the :warn log level defined in test.exs removes all
    # log function calls from the compiled code.

    # assert ExUnit.CaptureLog.capture_log(fn ->
    #          EventStore.append_event(@event, @metadata)
    #        end) =~ "FakeEvent: logging"
  end
end
