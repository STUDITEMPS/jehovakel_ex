defmodule Shared.DauerTest do
  use ExUnit.Case, async: true
  alias Shared.Dauer

  describe "valide?/1" do
    test "negative Dauer ist nicht valide" do
      assert Dauer.aus_stundenzahl(-0.1) |> Dauer.valide?() == false
    end

    test "positive Dauer ist valide" do
      assert Dauer.aus_stundenzahl(0.1) |> Dauer.valide?() == true
    end

    test "leere Dauer ist valide" do
      assert Dauer.aus_stundenzahl(0.0) |> Dauer.valide?() == true
      assert Dauer.aus_stundenzahl(0) |> Dauer.valide?() == true
    end
  end

  describe "parse!/1" do
    test "ISO8601 Format" do
      assert Dauer.parse!("PT6H30M") == Dauer.aus_stundenzahl(6.5)
    end
  end
end
