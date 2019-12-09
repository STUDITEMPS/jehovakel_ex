defmodule Shared.EventStore do
  defmacro __using__(_opts \\ []) do
    quote location: :keep, generated: true do
      @event_store_backend __MODULE__
      alias Shared.EventStoreEvent
      require Logger

      def append_event(domain_event, metadata) do
        stream_id = Shared.AppendableEvent.stream_id(domain_event)
        append_event(stream_id, domain_event, metadata)
      end

      def append_event(
            stream_uuid,
            domain_event,
            metadata
          ) do
        persisted_events = domain_event |> EventStoreEvent.wrap_for_persistence(metadata)

        case @event_store_backend.append_to_stream(stream_uuid, :any_version, persisted_events) do
          :ok ->
            log(stream_uuid, domain_event, metadata)
            {:ok, persisted_events}

          error ->
            error
        end
      end

      def all_events(stream_id \\ nil, opts \\ []) do
        {:ok, events} =
          case stream_id do
            nil -> @event_store_backend.read_all_streams_forward()
            stream_id when is_binary(stream_id) -> events_for_stream(stream_id)
          end

        if Keyword.get(opts, :unwrap, true) do
          Enum.map(events, &Shared.EventStoreEvent.unwrap/1)
        else
          events
        end
      end

      defp events_for_stream(stream_id) do
        case @event_store_backend.read_stream_forward(stream_id) do
          {:error, :stream_not_found} -> {:ok, []}
          {:ok, events} -> {:ok, events}
        end
      end

      defp log(stream_uuid, event, metadata) do
        # Checke hier schon, ob Shared.LoggableEvent Protocol implementiert ist.
        logged_event = Shared.LoggableEvent.to_log(event)

        Logger.info(fn ->
          "Appended event stream_uuid=#{stream_uuid} event=[#{logged_event}] metadata=#{
            metadata |> inspect
          }"
        end)
      end
    end
  end
end
