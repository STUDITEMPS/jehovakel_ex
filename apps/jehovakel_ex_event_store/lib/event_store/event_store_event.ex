defmodule Shared.EventStoreEvent do
  def wrap_for_persistence(events, metadata) do
    events = List.wrap(events)
    metadata = Enum.into(metadata, %{})

    Enum.map(events, fn event ->
      %EventStore.EventData{
        data: event,
        metadata: metadata
      }
    end)
  end
end
