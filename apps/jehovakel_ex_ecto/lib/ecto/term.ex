defmodule Shared.Ecto.Term do
  @moduledoc """
  Store any Elixir data (aka Erlang’s term) in Postgres.
  """
  @behaviour Ecto.Type
  def type, do: :binary
  def cast(term), do: {:ok, term}
  def load(bin), do: {:ok, bin |> :erlang.binary_to_term()}
  def dump(term), do: {:ok, term |> :erlang.term_to_binary()}
  def embed_as(_), do: :self
  def equal?(term1, term2), do: term1 == term2
end
