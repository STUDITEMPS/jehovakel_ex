defmodule Shared.EventStoreListenerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog
  @moduletag :integration

  @event %Shared.EventTest.FakeEvent{}

  defmodule EventHandlingError do
    defexception [:message]
  end

  defmodule Counter do
    use Agent

    def start_link(initial_value) do
      Agent.start_link(fn -> initial_value end, name: __MODULE__)
    end

    def increment do
      Agent.get_and_update(__MODULE__, &{&1, &1 + 1})
    end
  end

  defmodule ExampleConsumer do
    use Shared.EventStoreListener,
      subscription_key: "example_consumer",
      event_store: JehovakelEx.EventStore

    def handle(_event, %{test_pid: test_pid, raise_until: raise_until}) do
      case Counter.increment() do
        count when count <= raise_until ->
          send(test_pid, :exception_during_event_handling)
          raise EventHandlingError, "BAM BAM BAM"

        _ ->
          send(test_pid, :event_handled_successfully)
      end

      :ok
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
    start_supervised!(ExampleConsumer)
    Counter.start_link(0)

    on_exit(fn ->
      # stop eventstore application
      Application.stop(:eventstore)
      Process.exit(eventstore_connection, :shutdown)
    end)

    :ok
  end

  describe "Retry" do
    test "automatically on Exception during event handling without GenServer restart" do
      capture_log(fn ->
        {:ok, _events} =
          JehovakelEx.EventStore.append_event(@event, %{test_pid: self(), raise_until: 0})

        assert_receive :exception_during_event_handling
        assert_receive :event_handled_successfully
      end)
    end

    test "does not restart Listener process" do
      capture_log(fn ->
        listener_pid = Process.whereis(ExampleConsumer)

        {:ok, _events} =
          JehovakelEx.EventStore.append_event(@event, %{test_pid: self(), raise_until: 0})

        assert_receive :event_handled_successfully, 200
        assert listener_pid == Process.whereis(ExampleConsumer)
      end)
    end

    test "stops after 3 attempts" do
      logs =
        capture_log(fn ->
          listener_pid = Process.whereis(ExampleConsumer)

          {:ok, _events} =
            JehovakelEx.EventStore.append_event(@event, %{test_pid: self(), raise_until: 3})

          assert_receive :exception_during_event_handling
          assert_receive :event_handled_successfully, 200

          assert listener_pid != Process.whereis(ExampleConsumer)
        end)

      assert logs =~ "ExampleConsumer is retrying (1/3)"
      assert logs =~ "ExampleConsumer is retrying (2/3)"
      assert logs =~ "ExampleConsumer is retrying (3/3)"
      assert logs =~ "is dying due to bad event after 3 retries"
    end
  end

  test "Log Stacktrace on failing to handle exception during event handling" do
    logs =
      capture_log(fn ->
        {:ok, _events} =
          JehovakelEx.EventStore.append_event(@event, %{test_pid: self(), raise_until: 4})

        assert_receive :exception_during_event_handling
        assert_receive :event_handled_successfully, 300
      end)

    assert logs =~ "Stacktrace"
    assert logs =~ "BAM BAM BAM"
    assert logs =~ "Shared.EventStoreListenerTest.ExampleConsumer"
    assert logs =~ "lib/event_store/event_store_listener_test.exs"
  end
end
