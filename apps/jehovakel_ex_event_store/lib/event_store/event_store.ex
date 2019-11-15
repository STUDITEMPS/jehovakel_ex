defmodule Shared.EventStore do
  require Logger
  alias Shared.EventStoreEvent

  # FIXME: Die original append Funktion der EventStore Library nimmt eine Liste
  # von Events. Die log Funktion weiter unten auch. Die öffentliche Funktion
  # append_event dieses Moduls wiederum nur ein Event. Vgl. mit anderen Bounded
  # Contexten und mache es einheitlich.
  def append_event(event, metadata, event_store_backend \\ EventStore) do
    # metadata = Map.put(metadata, :stacktrace, Process.info(self(), :current_stacktrace))
    stream_id = Shared.AppendableEvent.stream_id(event)
    persisted_events = event |> EventStoreEvent.wrap_for_persistence(metadata)

    case event_store_backend.append_to_stream(stream_id, :any_version, persisted_events) do
      :ok ->
        log(stream_id, event, metadata)
        {:ok, persisted_events}

      error ->
        error
    end
  end

  def all_events(stream_id \\ nil, opts \\ []) do
    {:ok, events} =
      case stream_id do
        nil -> EventStore.read_all_streams_forward()
        stream_id when is_binary(stream_id) -> EventStore.read_stream_forward(stream_id)
      end

    if Keyword.get(opts, :unwrap, true) do
      Enum.map(events, &Shared.EventStoreEvent.unwrap/1)
    else
      events
    end
  end

  defp log(stream_uuid, events, metadata) do
    events = List.wrap(events)

    Enum.each(events, fn event ->
      # Checke hier schon, ob LoggableEvent Protocol implementiert ist.
      logged_event = LoggableEvent.to_log(event)

      Logger.info(fn ->
        "Appended event stream_uuid=#{stream_uuid} event=[#{logged_event}] metadata=#{
          metadata |> inspect
        }"
      end)
    end)
  end
end
