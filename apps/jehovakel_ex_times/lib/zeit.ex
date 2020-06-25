defmodule Shared.Zeit do
  alias Shared.Zeitperiode

  @spec mit_deutscher_zeitzone(date :: Date.t, time :: Time.t) :: DateTime.t
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

  @spec mit_deutscher_zeitzone(NaiveDateTime.t) :: DateTime.t
  def mit_deutscher_zeitzone(%NaiveDateTime{} = datetime) do
    datetime
    |> Timex.to_datetime("Europe/Berlin")
  end

  @spec mit_deutscher_zeitzone(DateTime.t) :: DateTime.t
  def mit_deutscher_zeitzone(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_naive()
    |> mit_deutscher_zeitzone()
  end

  @spec mit_deutscher_zeitzone(datum :: Date.t, start :: Time.t, ende :: Time.t) :: Timex.Interval.t()
  def mit_deutscher_zeitzone(%Date{} = datum, %Time{} = start, %Time{} = ende) do
    zeitperiode = Zeitperiode.new(datum, start, ende)

    Zeitperiode.new(
      Zeitperiode.von(zeitperiode) |> mit_deutscher_zeitzone(),
      Zeitperiode.bis(zeitperiode) |> mit_deutscher_zeitzone(),
      "Etc/UTC"
    )
  end

  @spec parse(binary) :: DateTime.t | NaiveDateTime.t
  def parse(to_parse) when is_binary(to_parse) do
    {:ok, date_time} = Timex.parse(to_parse, "{ISO:Extended}")
    date_time
  end

  @spec jetzt :: DateTime.t
  def jetzt do
    Timex.local() |> DateTime.truncate(:second)
  end

  defmodule Sigil do
    @spec sigil_G(binary, _ :: charlist()) :: DateTime.t
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
