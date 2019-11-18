# FIXME: Teste mich!!!
defmodule Timex.Ecto.DateTimeWithTimezone.Query do
  @moduledoc """
  Timex.Ecto.DateTimeWithTimezone ist ein zusammengesetzter Datentyp `{dt:datetimetz, tz:timezone}`. Beim Vergleich
  von diesen Datentypen muss man immer den `dt`-Teil dieses Datentyps vergleichen, ansonsten wird nur die String
  Repräsentation verglichen.
  """

  @doc """
  Compares 2 Datetimes with time zone using `=` operator.
  """
  defmacro datetime_equal(left, right)

  # left and right are both pinned variables
  defmacro datetime_equal({:^, _, _} = left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?).dt = (?).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # left is a pinned variable, right is a field in the database
  defmacro datetime_equal({:^, _, _} = left, right) do
    quote do
      fragment(
        "(?).dt = (?::datetimetz).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        unquote(right)
      )
    end
  end

  # left is a field in the database, right is a pinned variable
  defmacro datetime_equal(left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?::datetimetz).dt = (?).dt",
        unquote(left),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # both fields are database variables
  defmacro datetime_equal(left, right) do
    quote do
      fragment(
        "(?::datetimetz).dt = (?::datetimetz).dt",
        unquote(left),
        unquote(right)
      )
    end
  end

  @doc """
  Compares 2 Datetimes with time zone using `>` operator.
  """
  defmacro datetime_greater_than(left, right)

  # left and right are both pinned variables
  defmacro datetime_greater_than({:^, _, _} = left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?).dt > (?).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # left is a pinned variable, right is a field in the database
  defmacro datetime_greater_than({:^, _, _} = left, right) do
    quote do
      fragment(
        "(?).dt > (?::datetimetz).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        unquote(right)
      )
    end
  end

  # left is a field in the database, right is a pinned variable
  defmacro datetime_greater_than(left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?::datetimetz).dt > (?).dt",
        unquote(left),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # both fields are database variables
  defmacro datetime_greater_than(left, right) do
    quote do
      fragment(
        "(?::datetimetz).dt > (?::datetimetz).dt",
        unquote(left),
        unquote(right)
      )
    end
  end

  @doc """
  Compares 2 Datetimes with time zone using `>=` operator.
  """
  defmacro datetime_greater_than_or_equal(left, right)

  # left and right are both pinned variables
  defmacro datetime_greater_than_or_equal({:^, _, _} = left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?).dt >= (?).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # left is a pinned variable, right is a field in the database
  defmacro datetime_greater_than_or_equal({:^, _, _} = left, right) do
    quote do
      fragment(
        "(?).dt >= (?::datetimetz).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        unquote(right)
      )
    end
  end

  # left is a field in the database, right is a pinned variable
  defmacro datetime_greater_than_or_equal(left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?::datetimetz).dt >= (?).dt",
        unquote(left),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # both fields are database fields
  defmacro datetime_greater_than_or_equal(left, right) do
    quote do
      fragment(
        "(?::datetimetz).dt >= (?::datetimetz).dt",
        unquote(left),
        unquote(right)
      )
    end
  end

  @doc """
  Compares 2 Datetimes with time zone using `<` operator.
  """
  defmacro datetime_less_than(left, right)

  # left and right are both pinned variables
  defmacro datetime_less_than({:^, _, _} = left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?).dt < (?).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # left is a pinned variable, right is a field in the database
  defmacro datetime_less_than({:^, _, _} = left, right) do
    quote do
      fragment(
        "(?).dt < (?::datetimetz).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        unquote(right)
      )
    end
  end

  # left is a field in the database, right is a pinned variable
  defmacro datetime_less_than(left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?::datetimetz).dt < (?).dt",
        unquote(left),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # both fields are database variables
  defmacro datetime_less_than(left, right) do
    quote do
      fragment(
        "(?::datetimetz).dt < (?::datetimetz).dt",
        unquote(left),
        unquote(right)
      )
    end
  end

  @doc """
  Compares 2 Datetimes with time zone using `<=` operator.
  """
  defmacro datetime_less_than_or_equal(left, right)

  # left and right are both pinned variables
  defmacro datetime_less_than_or_equal({:^, _, _} = left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?).dt <= (?).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # left is a pinned variable, right is a field in the database
  defmacro datetime_less_than_or_equal({:^, _, _} = left, right) do
    quote do
      fragment(
        "(?).dt <= (?::datetimetz).dt",
        type(unquote(left), Timex.Ecto.DateTimeWithTimezone),
        unquote(right)
      )
    end
  end

  # left is a field in the database, right is a pinned variable
  defmacro datetime_less_than_or_equal(left, {:^, _, _} = right) do
    quote do
      fragment(
        "(?::datetimetz).dt <= (?).dt",
        unquote(left),
        type(unquote(right), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # both fields are database variables
  defmacro datetime_less_than_or_equal(left, right) do
    quote do
      fragment(
        "(?::datetimetz).dt <= (?::datetimetz).dt",
        unquote(left),
        unquote(right)
      )
    end
  end

  @doc """
    Tests two given intervals for overlap.
    math: [interval_start_left, interval_end_left) union [interval_start_right, interval_end_right) != Interval.empty

    Dieses Makro brauch dass auch datetime_less_than importiert wurde.

    source: https://stackoverflow.com/questions/3269434/whats-the-most-efficient-way-to-test-two-integer-ranges-for-overlap
  """
  defmacro datetime_intervals_overlap(
             interval_start_left,
             interval_end_left,
             interval_start_right,
             interval_end_right
           ) do
    quote do
      fragment(
        "(? and ?)",
        datetime_less_than(
          unquote(interval_start_left),
          unquote(interval_end_right)
        ),
        datetime_less_than(
          unquote(interval_start_right),
          unquote(interval_end_left)
        )
      )
    end
  end

  @doc """
  Casting for Datetimes with time zone, uses the datetime part only.
  Useful for `order_by`, for example
  """
  defmacro datetime_with_timezone(datetime)

  # `datetime` is a database pinned variable
  defmacro datetime_with_timezone({:^, _, _} = datetime) do
    quote do
      fragment(
        "(?).dt",
        type(unquote(datetime), Timex.Ecto.DateTimeWithTimezone)
      )
    end
  end

  # `datetime` is a database variable
  defmacro datetime_with_timezone(datetime) do
    quote do
      fragment("(?).dt::timestamptz", unquote(datetime))
    end
  end
end
