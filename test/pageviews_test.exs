defmodule PageviewsTest do
  use ExUnit.Case
  doctest Pageviews

  test "greets the world" do
    assert Pageviews.hello() == :world
  end
end
