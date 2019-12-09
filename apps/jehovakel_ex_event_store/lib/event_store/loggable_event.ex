defprotocol Shared.LoggableEvent do
  @doc "Converts an event to a loggable String"
  def to_log(event)
end

defimpl Shared.LoggableEvent, for: Any do
  def to_log(_event), do: raise(ArgumentError, "Implement the LoggableEvent Protocol")
end
