defmodule Shared.ZeitperiodeTest do
  use ExUnit.Case, async: true
  alias Shared.Zeitperiode, as: Periode
  import Support.TimeAssertionHelper

  test "wenn von ist kleiner als bis" do
    date = ~D[2018-03-20]
    von = ~T[10:00:00]
    bis = ~T[12:20:00]
    periode = Periode.new(date, von, bis)

    assert Periode.to_string(periode) == "[2018-03-20 10:00, 2018-03-20 12:20)"

    date = ~D[2018-03-20]
    von = ~T[10:00:00]
    bis = ~T[00:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.to_string(periode) == "[2018-03-20 10:00, 2018-03-21 00:00)"
  end

  test "wenn von ist größer als bis" do
    date = ~D[2018-03-20]
    von = ~T[21:20:00]
    bis = ~T[06:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.to_string(periode) == "[2018-03-20 21:20, 2018-03-21 06:00)"

    date = ~D[2018-03-21]
    von = ~T[00:00:00]
    bis = ~T[06:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.to_string(periode) == "[2018-03-21 00:00, 2018-03-21 06:00)"
  end

  test "wenn von ist glech bis" do
    date = ~D[2018-03-20]
    von = ~T[06:00:00]
    bis = ~T[06:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.to_string(periode) == "[2018-03-20 06:00, 2018-03-21 06:00)"

    date = ~D[2018-03-21]
    von = ~T[00:00:00]
    bis = ~T[00:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.to_string(periode) == "[2018-03-21 00:00, 2018-03-22 00:00)"
  end

  test "Dauer in Stunden" do
    date = ~D[2018-03-20]
    von = ~T[21:20:00]
    bis = ~T[06:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.dauer_in_stunden(periode) |> Float.round(2) == 8.67
  end

  test "Dauer als Duration" do
    date = ~D[2018-03-20]
    von = ~T[21:30:00]
    bis = ~T[06:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.dauer(periode) == Shared.Dauer.aus_stundenzahl(8.5)
  end

  test "Dauer in Minuten" do
    date = ~D[2018-03-20]
    von = ~T[21:20:00]
    bis = ~T[06:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.dauer_in_minuten(periode) == 520
  end

  test "Dauer in Minuten bei Mitternacht" do
    date = ~D[2018-03-20]
    von = ~T[23:00:00]
    bis = ~T[00:00:00]
    periode = Periode.new(date, von, bis)

    assert Periode.dauer_in_minuten(periode) == 60
  end

  describe "Überschneidung" do
    test "keine Überschneidung an den Rändern der Perioden" do
      periode = Periode.new(~D[2018-03-20], ~T[16:00:00], ~T[18:00:00])
      andere_periode = Periode.new(~D[2018-03-20], ~T[18:00:00], ~T[22:00:00])

      refute Periode.ueberschneidung?(periode, andere_periode)
    end

    test "bei Überschneidung der Periodele" do
      periode = Periode.new(~D[2018-03-20], ~T[16:00:00], ~T[18:00:00])
      andere_periode = Periode.new(~D[2018-03-20], ~T[17:00:00], ~T[22:00:00])
      assert Periode.ueberschneidung?(periode, andere_periode)
    end
  end

  describe "kann mit Zeiten mit Zeitzonen umgehen" do
    test "wenn es eine Zeitumstellung auf Sommerzeit gibt" do
      {:ok, start, _offset} = DateTime.from_iso8601("2018-03-24T22:00:00+01:00")
      {:ok, ende, _offset} = DateTime.from_iso8601("2018-03-25T04:00:00+02:00")

      periode = Periode.new(start, ende)

      assert Periode.dauer_in_stunden(periode) == 5.0
      assert to_string(periode.from) == "2018-03-24 22:00:00"
      assert to_string(periode.until) == "2018-03-25 03:00:00"
    end

    test "wenn es eine Zeitumstellung auf Winterzeit gibt" do
      start =
        Timex.to_datetime(
          %{year: 2018, month: 10, day: 27, hour: 22, minute: 0, second: 0},
          "Europe/Berlin"
        )

      ende =
        Timex.to_datetime(
          %{year: 2018, month: 10, day: 28, hour: 4, minute: 0, second: 0},
          "Europe/Berlin"
        )

      periode = Periode.new(start, ende)

      assert Periode.dauer_in_stunden(periode) == 7.0
      assert to_string(periode.from) == "2018-10-27 22:00:00"
      assert to_string(periode.until) == "2018-10-28 05:00:00"
    end

    test "wenn es keine Zeitumstellung gibt" do
      start =
        Timex.to_datetime(
          %{year: 2018, month: 9, day: 27, hour: 22, minute: 0, second: 0},
          "Europe/Berlin"
        )

      ende =
        Timex.to_datetime(
          %{year: 2018, month: 9, day: 28, hour: 4, minute: 0, second: 0},
          "Europe/Berlin"
        )

      periode = Periode.new(start, ende)

      assert Periode.dauer_in_stunden(periode) == 6.0
      assert to_string(periode.from) == "2018-09-27 22:00:00"
      assert to_string(periode.until) == "2018-09-28 04:00:00"
    end

    test "wenn es eine Zeitumstellung auf Sommerzeit gibt und die Zeit in UTC vorliegt" do
      start =
        Timex.to_datetime(
          %{year: 2018, month: 3, day: 24, hour: 21, minute: 0, second: 0},
          "Etc/UTC"
        )

      ende =
        Timex.to_datetime(
          %{year: 2018, month: 3, day: 25, hour: 2, minute: 0, second: 0},
          "Etc/UTC"
        )

      periode = Periode.new(start, ende)

      assert Periode.dauer_in_stunden(periode) == 5.0
      assert to_string(periode.from) == "2018-03-24 22:00:00"
      assert to_string(periode.until) == "2018-03-25 03:00:00"
    end

    test "wenn es eine Zeitumstellung auf Winterzeit gibt und die Zeit in UTC vorliegt" do
      start =
        Timex.to_datetime(
          %{year: 2018, month: 10, day: 27, hour: 20, minute: 0, second: 0},
          "Etc/UTC"
        )

      ende =
        Timex.to_datetime(
          %{year: 2018, month: 10, day: 28, hour: 3, minute: 0, second: 0},
          "Etc/UTC"
        )

      periode = Periode.new(start, ende)

      assert Periode.dauer_in_stunden(periode) == 7.0
      assert to_string(periode.from) == "2018-10-27 22:00:00"
      assert to_string(periode.until) == "2018-10-28 05:00:00"
    end

    test "wenn es keine Zeitumstellung gibt und die Zeit in UTC vorliegt" do
      start =
        Timex.to_datetime(
          %{year: 2018, month: 9, day: 27, hour: 20, minute: 0, second: 0},
          "Etc/UTC"
        )

      ende =
        Timex.to_datetime(
          %{year: 2018, month: 9, day: 28, hour: 2, minute: 0, second: 0},
          "Etc/UTC"
        )

      periode = Periode.new(start, ende)

      assert Periode.dauer_in_stunden(periode) == 6.0
      assert to_string(periode.from) == "2018-09-27 22:00:00"
      assert to_string(periode.until) == "2018-09-28 04:00:00"
    end

    test "Zeitumstellung und die Zeitzone kann nun geparsed werden kann" do
      interval = "2018-10-27T17:00:00+02:00/2018-10-28T10:00:00+01:00"
      assert periode = Periode.from_interval(interval)
      assert Periode.dauer_in_stunden(periode) == 18.0

      interval = "2019-03-30T22:00:00+01:00/2019-03-31T07:00:00+02:00"
      assert periode = Periode.from_interval(interval)
      assert Periode.dauer_in_stunden(periode) == 8.0

      interval = "2019-03-30T22:00:00+01:00/2019-03-31T04:00:00+02:00"
      assert periode = Periode.from_interval(interval)
      assert Periode.dauer_in_stunden(periode) == 5.0
    end
  end

  describe "from_interval/1" do
    test "parse Interval und erstelle eine neue Zeitperiode" do
      interval = "2018-09-27T17:00:00+02:00/2018-09-28T10:00:00+02:00"

      assert periode = Periode.from_interval(interval)
      assert Periode.dauer_in_stunden(periode) == 17.0
      assert Periode.von(periode) == ~N(2018-09-27 17:00:00)
      assert Periode.bis(periode) == ~N(2018-09-28 10:00:00)
    end
  end

  describe "parse_interval/1" do
    test "parse ISO8601 Zeitintervall" do
      assert Periode.parse("2019-04-16T23:30:00+02:00/2019-04-16T23:45:00+02:00")
             |> entspricht_intervall?("2019-04-16T23:30:00+02:00/2019-04-16T23:45:00+02:00")
    end
  end

  describe "teil_von?/2" do
    test "erkennt, ob ein Periode komplett in einem anderen Periode liegt" do
      periode = Periode.new(~D[2018-03-20], ~T[23:00:00], ~T[00:00:00])

      refute periode |> Periode.teil_von?(periode)

      refute Periode.new(~D[2018-03-20], ~T[23:00:00], ~T[01:00:00])
             |> Periode.teil_von?(periode)

      refute Periode.new(~D[2018-03-20], ~T[23:30:00], ~T[00:00:00])
             |> Periode.teil_von?(periode)

      refute Periode.new(~D[2018-03-20], ~T[22:30:00], ~T[23:00:00])
             |> Periode.teil_von?(periode)

      refute Periode.new(~D[2018-03-20], ~T[23:30:00], ~T[01:00:00])
             |> Periode.teil_von?(periode)

      assert Periode.new(~D[2018-03-20], ~T[23:30:00], ~T[23:45:00])
             |> Periode.teil_von?(periode)
    end
  end
end
