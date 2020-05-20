defmodule Shared.AppendableEventTest do
  use ExUnit.Case, async: true
  require Protocol

  defmodule Event do
    defstruct [:a, :b, :c, :d]
  end

  describe "derive" do
    setup do
      {:ok, %{event: %Event{a: "a", b: "b", c: nil, d: %{foo: :bar}}}}
    end

    test "Event id is a single Field", %{event: event} do
      Protocol.derive(Shared.AppendableEvent, Event, :a)

      assert Shared.AppendableEvent.stream_id(event) == "a"
      assert Shared.AppendableEvent.streams_to_link(event) == []
    end

    test "Derive a list, first field is the stream id, rest are links", %{event: event} do
      Protocol.derive(Shared.AppendableEvent, Event, [:a, :b])

      assert Shared.AppendableEvent.stream_id(event) == "a"
      assert Shared.AppendableEvent.streams_to_link(event) == ["b"]
    end

    test "Stream id needs to be present", %{event: event} do
      Protocol.derive(Shared.AppendableEvent, Event, :c)

      assert_raise ArgumentError, "Stream ID has to be a string, got 'nil'.", fn ->
        Shared.AppendableEvent.stream_id(event)
      end
    end

    test "Stream id needs to be a string", %{event: event} do
      Protocol.derive(Shared.AppendableEvent, Event, :d)

      assert_raise ArgumentError, "Stream ID has to be a string, got '%{foo: :bar}'.", fn ->
        Shared.AppendableEvent.stream_id(event)
      end
    end

    test "all Links need to be present", %{event: event} do
      Protocol.derive(Shared.AppendableEvent, Event, [:a, :c])

      assert_raise ArgumentError,
                   "Streams ids to link need to be a string, got 'c -> nil'.",
                   fn ->
                     Shared.AppendableEvent.streams_to_link(event)
                   end
    end

    test "all links need to be strings", %{event: event} do
      Protocol.derive(Shared.AppendableEvent, Event, [:a, :c, :d])

      assert_raise ArgumentError,
                   "Streams ids to link need to be a string, got 'c -> nil, d -> %{foo: :bar}'.",
                   fn ->
                     Shared.AppendableEvent.streams_to_link(event)
                   end
    end
  end
end
