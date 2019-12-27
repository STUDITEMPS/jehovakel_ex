defmodule JehovakelExEcto.Repo.Migrations.CreateDateTimeWithTimezoneCustomType do
  use Ecto.Migration

  defdelegate up(), to: Timex.Ecto.DateTimeWithTimezone.Migration
  defdelegate down(), to: Timex.Ecto.DateTimeWithTimezone.Migration
end
