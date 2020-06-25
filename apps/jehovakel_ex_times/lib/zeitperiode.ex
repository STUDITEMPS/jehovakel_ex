defmodule Shared.Zeitperiode do
  @moduledoc """
  Repräsentiert eine Arbeitszeit-Periode oder Schicht
  """
  @type t :: Timex.Interval.t()
  @type interval :: [start: DateTime.t | NaiveDateTime.t, ende: DateTime.t | NaiveDateTime.t]
  @default_base_timezone_name "Europe/Berlin"

  @spec new(kalendertag :: Date.t, von :: Time.t, bis :: Time.t) :: t
  def new(%Date{} = kalendertag, %Time{} = von, %Time{} = bis) when von < bis do
    von_als_datetime = to_datetime(kalendertag, von)
    bis_als_datetime = to_datetime(kalendertag, bis)

    to_interval(von_als_datetime, bis_als_datetime)
  end

  def new(%Date{} = kalendertag, %Time{} = von, %Time{} = bis) when von >= bis do
    von_als_datetime = to_datetime(kalendertag, von)

    next_day = Timex.shift(kalendertag, days: 1)
    bis_als_datetime = to_datetime(next_day, bis)

    to_interval(von_als_datetime, bis_als_datetime)
  end

  # Basiszeitzone ist die Zeitzone, in der die Zeit erfasst wurde, aktuell immer Dtl.
  @spec new(von :: DateTime.t, bis :: DateTime.t, base_timezone_name :: String.t) :: t
  def new(%DateTime{} = von, %DateTime{} = bis, base_timezone_name) do
    von = Shared.Zeitperiode.Timezone.convert(von, base_timezone_name)

    bis = Shared.Zeitperiode.Timezone.convert(bis, base_timezone_name)

    base_timezone_von = Shared.Zeitperiode.Timezone.timezone_info_for(von, base_timezone_name)
    base_timezone_bis = Shared.Zeitperiode.Timezone.timezone_info_for(bis, base_timezone_name)
    summertime_offset = base_timezone_bis.offset_std - base_timezone_von.offset_std

    von_naive = von |> DateTime.to_naive()

    bis_naive =
      bis
      |> DateTime.to_naive()
      |> Timex.shift(seconds: -summertime_offset)

    to_interval(von_naive, bis_naive)
  end

  @spec new(von :: DateTime.t, bis :: DateTime.t) :: t
  def new(%DateTime{} = von, %DateTime{} = bis) do
    # default value using `\\` produces the warning `definitions with multiple clauses and default values require a header.`
    new(von, bis, @default_base_timezone_name)
  end

  @spec new(von :: NaiveDateTime.t, bis :: NaiveDateTime.t) :: t
  def new(%NaiveDateTime{} = von, %NaiveDateTime{} = bis), do: to_interval(von, bis)

  @spec from_interval(interval :: String.t) :: t
  def from_interval(interval) when is_binary(interval) do
    [start: start, ende: ende] = parse_interval(interval)
    new(start, ende)
  end

  @spec von(t) :: Timex.Types.valid_datetime()
  def von(periode), do: periode.from

  @spec bis(t) :: Timex.Types.valid_datetime()
  def bis(periode), do: periode.until

  @spec von_datum(t) :: Date.t
  def von_datum(periode), do: periode |> von() |> NaiveDateTime.to_date()

  @spec bis_datum(t) :: Date.t
  def bis_datum(%{until: %{hour: 0, minute: 0, second: 0}} = periode) do
    periode |> bis() |> NaiveDateTime.to_date() |> Timex.shift(days: -1)
  end

  def bis_datum(periode) do
    periode |> bis() |> NaiveDateTime.to_date()
  end

  @spec dauer(t) :: number | {:error, any} | Timex.Duration.t()
  def dauer(periode), do: duration(periode, :duration)
  @spec dauer_in_stunden(t) :: number | {:error, any} | Timex.Duration.t()
  def dauer_in_stunden(periode), do: duration(periode, :hours)
  @spec dauer_in_minuten(t) :: number | {:error, any} | Timex.Duration.t()
  def dauer_in_minuten(periode), do: duration(periode, :minutes)

  @spec ueberschneidung?(periode :: t, andere_periode :: t) :: boolean
  def ueberschneidung?(periode, andere_periode) do
    periode.from in andere_periode || andere_periode.from in periode
  end

  @spec teil_von?(zu_testende_periode :: t, periode :: t) :: boolean
  def teil_von?(zu_testende_periode, periode) do
    zu_testende_periode.from in periode && zu_testende_periode.until in periode
  end

  @spec beginnt_vor?(periode1 :: t, periode2 :: t) :: boolean
  def beginnt_vor?(periode1, periode2) do
    NaiveDateTime.compare(periode1.from, periode2.from) == :lt
  end

  @spec to_string(t) :: String.t
  def to_string(periode), do: Timex.Interval.format!(periode, "%Y-%m-%d %H:%M", :strftime)

  defp to_interval(von, bis) do
    Timex.Interval.new(
      from: von,
      until: bis,
      left_open: false,
      right_open: true,
      step: [seconds: 1]
    )
  end

  @deprecated "Use parse/1 instead"
  def parse_interval(interval) when is_binary(interval) do
    parse(interval)
  end

  @spec parse(binary) :: interval()
  def parse(interval) when is_binary(interval) do
    [start, ende] =
      interval
      |> String.split("/")

    [start: start |> Shared.Zeit.parse(), ende: ende |> Shared.Zeit.parse()]
  end

  @deprecated "Use Shared.Zeit.parse/1 instead"
  def parse_time(time) when is_binary(time) do
    Shared.Zeit.parse(time)
  end

  defp to_datetime(date, time) do
    {:ok, naive_datetime} = NaiveDateTime.new(date, time)
    naive_datetime
  end

  defp duration(periode, :duration), do: Timex.Interval.duration(periode, :duration)

  defp duration(periode, :hours),
    do: periode |> duration(:duration) |> Timex.Duration.to_hours()

  defp duration(periode, :minutes),
    do: periode |> duration(:duration) |> Timex.Duration.to_minutes() |> Float.round()

  @spec dauer_der_ueberschneidung(periode1 :: Timex.Interval.t(), periode2 :: Timex.Interval.t()) :: Timex.Duration.t()
  def dauer_der_ueberschneidung(periode1, periode2) do
    dauer1 = dauer(periode1)

    dauer_differenz =
      case Timex.Interval.difference(periode1, periode2) do
        [] -> Shared.Dauer.leer()
        [periode] -> dauer(periode)
        [periode1, periode2] -> Shared.Dauer.addiere(dauer(periode1), dauer(periode2))
      end

    Shared.Dauer.subtrahiere(dauer1, dauer_differenz)
  end

  defmodule Timezone do
    @spec convert(DateTime.t, binary() | Timex.AmbiguousTimezoneInfo.t() | Timex.TimezoneInfo.t()) :: DateTime.t | Timex.AmbiguousDateTime.t()
    def convert(datetime, timezone) do
      case Timex.Timezone.convert(datetime, timezone) do
        {:error, _} ->
          shifted = %{datetime | hour: datetime.hour + 1}
          converted = Timex.Timezone.convert(shifted, timezone)
          _shifted_back = %{converted | hour: converted.hour - 1}

        converted ->
          converted
      end
    end

    def timezone_info_for(time, timezone_name) do
      case Timex.Timezone.get(timezone_name, time) do
        # 02:00 - 03:00 day of the summer time / winter time switch
        {:error, _} ->
          # Timex.shift/2 funktioniert nicht, weil dann dieselbe Exception geworfen wird
          time = %{time | hour: time.hour + 1}
          Timex.Timezone.get(timezone_name, time)

        %Timex.TimezoneInfo{} = timezone_info ->
          timezone_info
      end
    end
  end
end
