defmodule ClisaurusTest do
  use ExUnit.Case
  doctest Clisaurus

  test "greets the world" do
    assert Clisaurus.hello() == :world
  end
end
