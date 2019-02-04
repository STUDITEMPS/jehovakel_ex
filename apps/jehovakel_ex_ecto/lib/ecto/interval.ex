defmodule Shared.Ecto.Interval do
  @behaviour Ecto.Type
  def type, do: :interval

  def cast(%Timex.Duration{} = duration) do
    {:ok, duration}
  end

  def cast(duration) when is_float(duration) do
    duration
    |> float_hours_to_seconds
    |> Timex.Duration.from_seconds()
    |> cast
  end

  def cast(_) do
    :error
  end

  def dump(%Timex.Duration{megaseconds: megaseconds, microseconds: 0, seconds: remainder_seconds})
      when is_integer(remainder_seconds) and is_integer(megaseconds) do
    seconds = megaseconds_to_seconds(megaseconds) + remainder_seconds

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

  defp megaseconds_to_seconds(megaseconds), do: megaseconds * 1_000_000
  defp seconds_per_day, do: 60 * 60 * 24

  defp seconds_to_days_and_remainder_seconds(seconds) do
    {div(seconds, seconds_per_day()), rem(seconds, seconds_per_day())}
  end

  defp float_hours_to_seconds(hours) do
    round(hours * 60 * 60)
  end
end
