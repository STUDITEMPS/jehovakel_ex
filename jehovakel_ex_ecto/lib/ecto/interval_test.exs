defmodule Shared.Ecto.IntervalTest do
  use ExUnit.Case, async: true
  alias Shared.Ecto.Interval, as: Interval

  @timex_duration Timex.Duration.from_hours(8)
  @db_interval %Postgrex.Interval{
    months: 0,
    days: 0,
    secs: 8 * 60 * 60
  }

  test "type" do
    assert Interval.type() == :interval
  end

  test "cast/1 accepts binaries as float hours" do
    assert Interval.cast("8.5") == {:ok, Timex.Duration.from_hours(8.5)}
  end

  test "cast/1 does not accept binaries if they cannot be parsed entirely" do
    assert Interval.cast("8.5foo") == :error
  end

  test "cast/1 accepts Timex.Duration" do
    assert Interval.cast(@timex_duration) == {:ok, @timex_duration}
  end

  test "cast/1 converts Float as Hours into Timex.Duration" do
    assert Interval.cast(1.5) == {:ok, Timex.Duration.from_minutes(90)}
  end

  test "cast/1 accepts no other type" do
    assert Interval.cast(1) == :error
  end

  test "load/1 converts a value from the database (interval) into the custom type (Timex.Duration)" do
    assert Interval.load(@db_interval) == {:ok, @timex_duration}
  end

  test "load/1 accepts no other type" do
    assert Interval.load(:foo) == :error
  end

  test "dump/1 converts a Timex Duration to a Postgres Interval" do
    assert Interval.dump(@timex_duration) == {:ok, @db_interval}
  end

  test "dump/1 converts a Float as Hours to a Postgres Interval" do
    assert Interval.dump(1.5) == {:ok, %Postgrex.Interval{months: 0, days: 0, secs: 5400}}
  end

  test "dump/1 converts a value with megaseconds to database" do
    assert Interval.dump(%Timex.Duration{megaseconds: 3, seconds: 776_700, microseconds: 0}) ==
             {:ok,
              %Postgrex.Interval{
                months: 0,
                days: 43,
                secs: 61_500
              }}
  end

  test "dump/1 converts a value with microseconds" do
    assert Interval.dump(%Timex.Duration{megaseconds: 0, seconds: 45_644, microseconds: 40_000}) ==
             {:ok,
              %Postgrex.Interval{
                months: 0,
                days: 0,
                secs: 45_644
              }}
  end

  test "load/1 mit days" do
    assert Interval.load(%Postgrex.Interval{
             months: 0,
             days: 43,
             secs: 61_500
           }) == {:ok, %Timex.Duration{microseconds: 0, seconds: 776_700, megaseconds: 3}}
  end

  test "dump/1 accepts no other type" do
    assert Interval.load("bar") == :error
  end
end
