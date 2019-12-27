defmodule Timex.Ecto.DateTimeWithTimezone do
  @moduledoc """
  This is a special type for storing datetime + timezone information as a composite type.

  To use this, you must first make sure you have the `datetimetz` type defined in your database:

  ```
    defmodule YourMigration do
      use Ecto.Migration

      defdelegate up(), to: Timex.Ecto.DateTimeWithTimezone.Migration
      defdelegate down(), to: Timex.Ecto.DateTimeWithTimezone.Migration
    end
  ```

  WARNING: In Embeds, the timezone does not get preserved.
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :datetimetz

  @doc """
  Handle casting to Timex.Ecto.DateTimeWithTimezone
  """
  def cast(%DateTime{} = datetime), do: {:ok, datetime}

  # TODO: Implement casting/loading for Jason.encode() and Jason.decode()
  # TODO: Get rid of all the unnecessary code copied from ecto 2.x

  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISO:Extended}") do
      {:ok, datetime} -> {:ok, datetime |> DateTime.truncate(:second)}
      {:error, _} -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({%DateTime{} = dt, timezone}) do
    timezone =
      case Timex.Timezone.get(timezone, dt) do
        %Timex.AmbiguousTimezoneInfo{after: winter_time_zone} -> winter_time_zone
        %Timex.TimezoneInfo{} = timezone -> timezone
      end

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

  @doc """
  Checks if two terms are semantically equal.
  """
  def equal?(term1, term2), do: term1 == term2

  @doc """
  Dictates how the type should be treated inside embeds.
  """
  def embed_as(_), do: :self

  defmodule Migration do
    use Ecto.Migration

    def up do
      execute("CREATE TYPE datetimetz AS (dt timestamptz, tz varchar);")
    end

    def down do
      execute("DROP TYPE IF EXISTS datetimetz;")
    end
  end
end
