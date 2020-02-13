defmodule Shared.Zeit do
  alias Shared.Zeitperiode

  @doc """
  Wandelt ein Datum und eine Zeit in ein DateTime Struct mit deutscher Zeitzone
  um. Es wird also angenommen, dass die übergebene Zeit in Deutschland statt
  fand.

  iex> Shared.Zeit.mit_deutscher_zeitzone(~D[2018-04-22], ~T[15:00:00])
  #DateTime<2018-04-22 15:00:00+02:00 CEST Europe/Berlin>
  """
  def mit_deutscher_zeitzone(%Date{} = date, %Time{} = time) do
    {:ok, datetime} = NaiveDateTime.new(date, time)

    datetime
    |> mit_deutscher_zeitzone()
  end

  def mit_deutscher_zeitzone(%NaiveDateTime{} = datetime) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> mit_deutscher_zeitzone()
  end

  def mit_deutscher_zeitzone(%DateTime{} = datetime) do
    datetime
    |> Timex.set(timezone: "Europe/Berlin")
  end

  def mit_deutscher_zeitzone(%Date{} = datum, %Time{} = start, %Time{} = ende) do
    zeitperiode = Zeitperiode.new(datum, start, ende)

    Zeitperiode.new(
      Zeitperiode.von(zeitperiode) |> mit_deutscher_zeitzone(),
      Zeitperiode.bis(zeitperiode) |> mit_deutscher_zeitzone(),
      "Etc/UTC"
    )
  end

  def parse(to_parse) when is_binary(to_parse) do
    {:ok, date_time} = Timex.parse(to_parse, "{ISO:Extended}")
    date_time
  end

  def jetzt do
    Timex.local() |> DateTime.truncate(:second)
  end

  defmodule Sigil do
    @doc """
    Wandelt ISO8601 Date Strings und Time Strings in DateTime mit deutscher Zeitzone

    ## Examples

      iex> ~G[2018-04-03 17:20:00]
      #DateTime<2018-04-03 17:20:00+02:00 CEST Europe/Berlin>

    """
    def sigil_G(string, []) do
      # [date_string, time_string] = String.split(string)
      # date = Date.from_iso8601!(date_string)
      # time = Time.from_iso8601!(time_string)
      naive = NaiveDateTime.from_iso8601!(string)
      Shared.Zeit.mit_deutscher_zeitzone(naive)
    end
  end
end
