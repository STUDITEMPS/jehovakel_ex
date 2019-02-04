defprotocol Shared.AppendableEvent do
  @doc "Returns the stream ID to which the event could be appended."
  def stream_id(event)
end

defimpl Shared.AppendableEvent, for: Any do
  # No default available
  def stream_id(_event), do: raise(ArgumentError, "Implement the Appendable Protocol")
end
