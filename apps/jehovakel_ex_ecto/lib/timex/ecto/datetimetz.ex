defmodule Timex.Ecto.DateTimeWithTimezone do
  @moduledoc """
  This is a special type for storing datetime + timezone information as a composite type.

  To use this, you must first make sure you have the `datetimetz` type defined in your database:

  ```sql
  CREATE TYPE datetimetz AS (
      dt timestamptz,
      tz varchar
  );
  ```

  Then you can use that type when creating your table, i.e.:

  ```sql
  CREATE TABLE example (
    id integer,
    created_at datetimetz
  );
  ```

  That's it!
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :datetimetz

  @doc """
  Handle casting to Timex.Ecto.DateTimeWithTimezone
  """
  def cast(%DateTime{} = datetime), do: {:ok, datetime}
  # Support embeds_one/embeds_many
  def cast(%{
        "calendar" => _cal,
        "year" => y,
        "month" => m,
        "day" => d,
        "hour" => h,
        "minute" => mm,
        "second" => s,
        # "ms" => ms,
        "timezone" => %{
          "full_name" => tzname,
          "abbreviation" => abbr,
          "offset_std" => offset_std,
          "offset_utc" => offset_utc
        }
      }) do
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :microsecond => {0, 0},
      :time_zone => tzname,
      :zone_abbr => abbr,
      :utc_offset => offset_utc,
      :std_offset => offset_std
    }

    {:ok, dt}
  end

  def cast(%{
        "calendar" => _cal,
        "year" => y,
        "month" => m,
        "day" => d,
        "hour" => h,
        "minute" => mm,
        "second" => s,
        # "microsecond" => us,
        "time_zone" => tzname,
        "zone_abbr" => abbr,
        "utc_offset" => offset_utc,
        "std_offset" => offset_std
      }) do
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :microsecond => {0, 0},
      :time_zone => tzname,
      :zone_abbr => abbr,
      :utc_offset => offset_utc,
      :std_offset => offset_std
    }

    {:ok, dt}
  end

  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISO:Extended}") do
      {:ok, datetime} -> {:ok, datetime |> DateTime.truncate(:second)}
      {:error, _} -> :error
    end
  end

  def cast(input) when is_map(input) do
    case Timex.Convert.convert_map(input) do
      %DateTime{} = d ->
        {:ok, d |> DateTime.truncate(:second)}

      %_{} = result ->
        case Timex.to_datetime(result, "Etc/UTC") do
          {:error, _} ->
            case Ecto.DateTime.cast(input) do
              {:ok, d} ->
                # FIXME: funktioniert ja eh nicht mehr
                load({{{d.year, d.month, d.day}, {d.hour, d.min, d.sec, d.usec}}, "Etc/UTC"})

              :error ->
                :error
            end

          %DateTime{} = d ->
            {:ok, d |> DateTime.truncate(:second)}
        end

      {:error, _} ->
        :error
    end
  end

  def cast(input) do
    case Timex.to_datetime(input, "Etc/UTC") do
      {:error, _} ->
        case Ecto.DateTime.cast(input) do
          {:ok, d} ->
            # FIXME: funktioniert ja eh nicht mehr
            load({{{d.year, d.month, d.day}, {d.hour, d.min, d.sec, d.usec}}, "Etc/UTC"})

          :error ->
            :error
        end

      %DateTime{} = d ->
        {:ok, d |> DateTime.truncate(:second)}
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({%DateTime{} = dt, timezone}) do
    # FIXME: handle AmbiguousDateTime
    dt_with_timezone = Timex.set(dt, timezone: timezone, microsecond: {0, 0})

    {:ok, dt_with_timezone}
  end

  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump(%DateTime{time_zone: tzname} = datetime) do
    in_utc = Timex.set(datetime, timezone: "Etc/UTC")
    {:ok, {in_utc, tzname}}
  end
end
