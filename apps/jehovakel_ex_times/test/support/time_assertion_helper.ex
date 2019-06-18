defmodule Support.TimeAssertionHelper do
  def entspricht_timestamp?(actual_datetime, expected_iso8601_timestamp) do
    DateTime.to_iso8601(actual_datetime) == expected_iso8601_timestamp
  end

  def entspricht_intervall?([start: start, ende: ende], expected_iso8601_interval) do
    DateTime.to_iso8601(start) <> "/" <> DateTime.to_iso8601(ende) == expected_iso8601_interval
  end

  def parse_datetime(binary), do: Shared.Zeit.parse(binary)
  def parse_interval(interval), do: Shared.Zeitperiode.parse(interval)
end
