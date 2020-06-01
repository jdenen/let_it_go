defmodule LetItGoTest do
  use ExUnit.Case
  doctest LetItGo

  test "greets the world" do
    assert LetItGo.hello() == :world
  end
end
