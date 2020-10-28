defmodule Shared.Ecto.TermTest do
  use ExUnit.Case, async: true
  alias Shared.Ecto.Term, as: Term

  defmodule FooTerm do
    defstruct [:atom_key]
  end

  def elixir_term do
    %FooTerm{atom_key: %{"bar" => 23}}
  end

  def db_term do
    elixir_term() |> :erlang.term_to_binary()
  end

  test "type" do
    assert Term.type() == :binary
  end

  test "cast/1 accepts any type and returns the value (there are no custom casting rules)" do
    assert Term.cast(elixir_term()) == {:ok, elixir_term()}
  end

  test "load/1 converts a value from the database (binary) into the elixir term" do
    assert Term.load(db_term()) == {:ok, elixir_term()}
  end

  test "dump/1 converts any value to erlang binary" do
    assert Term.dump(elixir_term()) == {:ok, db_term()}
  end
end
