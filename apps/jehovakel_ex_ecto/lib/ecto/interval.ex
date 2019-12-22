defmodule Shared.Ecto.Interval do
  @behaviour Ecto.Type
  def type, do: :interval

  def cast(%Timex.Duration{} = duration) do
    {:ok, duration}
  end

  def cast(duration_as_binary) when is_binary(duration_as_binary) do
    case Float.parse(duration_as_binary) do
      {duration, ""} -> cast(duration)
      _ -> cast(:error)
    end
  end

  def cast(duration) when is_float(duration) do
    duration
    |> float_hours_to_seconds
    |> Timex.Duration.from_seconds()
    |> cast()
  end

  def cast(%{"megaseconds" => megaseconds, "microseconds" => microseconds, "seconds" => seconds}) do
    {:ok, %Timex.Duration{megaseconds: megaseconds, microseconds: microseconds, seconds: seconds}}
  end

  def cast(_) do
    :error
  end

  def dump(%Timex.Duration{
        megaseconds: megaseconds,
        microseconds: microseconds,
        seconds: remainder_seconds
      })
      when is_integer(remainder_seconds) and is_integer(microseconds) and is_integer(megaseconds) do
    seconds =
      megaseconds_to_seconds(megaseconds) + microseconds_to_seconds(microseconds) +
        remainder_seconds

    {days, new_remainder_seconds} = seconds_to_days_and_remainder_seconds(seconds)

    {:ok, %Postgrex.Interval{months: 0, days: days, secs: new_remainder_seconds}}
  end

  def dump(duration) when is_float(duration) do
    {:ok, timex_duration} =
      duration
      |> cast

    dump(timex_duration)
  end

  def dump(_) do
    :error
  end

  def load(%Postgrex.Interval{months: 0, days: days, secs: seconds}) do
    {:ok, Timex.Duration.from_seconds(days * seconds_per_day() + seconds)}
  end

  def load(_) do
    :error
  end

  def embed_as(_), do: :self

  def equal?(interval1, interval2), do: interval1 == interval2

  defp megaseconds_to_seconds(megaseconds), do: megaseconds * 1_000_000
  defp microseconds_to_seconds(microseconds), do: round(microseconds / 1_000_000)
  defp seconds_per_day, do: 60 * 60 * 24

  defp seconds_to_days_and_remainder_seconds(seconds) do
    {div(seconds, seconds_per_day()), rem(seconds, seconds_per_day())}
  end

  defp float_hours_to_seconds(hours) do
    round(hours * 60 * 60)
  end
end

if Code.ensure_loaded?(Jason) do
  defimpl Jason.Encoder, for: Timex.Duration do
    def encode(duration, opts) do
      Jason.Encode.map(Map.take(duration, [:megaseconds, :microseconds, :seconds]), opts)
    end
  end
end
