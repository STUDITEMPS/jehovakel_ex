defmodule Shared.Dauer do
  @type t :: Timex.Duration.t()

  defdelegate aus_stundenzahl(stunden_als_float_oder_integer), to: Timex.Duration, as: :from_hours
  defdelegate aus_minutenzahl(minuten_als_integer), to: Timex.Duration, as: :from_minutes
  defdelegate aus_sekundenzahl(sekunden_als_integer), to: Timex.Duration, as: :from_seconds

  defdelegate in_stunden(dauer), to: Timex.Duration, as: :to_hours
  defdelegate in_minuten(dauer), to: Timex.Duration, as: :to_minutes
  defdelegate in_sekunden(dauer), to: Timex.Duration, as: :to_seconds

  defdelegate negiere(dauer), to: Timex.Duration, as: :invert
  defdelegate addiere(dauer, zweite_dauer), to: Timex.Duration, as: :add
  defdelegate subtrahiere(dauer, zweite_dauer), to: Timex.Duration, as: :sub
  # typ :microseconds, :milliseconds, :seconds, :minutes, :hours, :days, or :weeks
  defdelegate differenz(dauer, zweite_dauer, typ), to: Timex.Duration, as: :diff
  def differenz(dauer, zweite_dauer), do: differenz(dauer, zweite_dauer, :seconds)

  def leer, do: Shared.Dauer.aus_stundenzahl(0)

  def groesser_als?(dauer, zweite_dauer), do: Shared.Dauer.differenz(dauer, zweite_dauer) > 0
  def kleiner_als?(dauer, zweite_dauer), do: Shared.Dauer.differenz(dauer, zweite_dauer) < 0

  def valide?(dauer) do
    dauer == Timex.Duration.abs(dauer)
  end

  def parse!(dauer_als_string) when is_binary(dauer_als_string) do
    {:ok, dauer} = Timex.Duration.parse(dauer_als_string)
    dauer
  end
end
