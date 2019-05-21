defmodule PageviewsTopviewTest do
  use ExUnit.Case
  alias Pageviews.Topviews

  setup do
    {:ok, pid} = Topviews.start()

    on_exit(fn -> Agent.stop(pid) end)

    {:ok, pid: pid}
  end

  test "add line", state do
    pid = state[:pid]
    :ok = Topviews.add_pageview(pid, {"hi", 5})
    assert([{"hi", 5}], Topviews.get_top(pid))
  end

  test "sort lines", state do
    pid = state[:pid]
    Topviews.add_pageview(pid, {"test1", 5})
    Topviews.add_pageview(pid, {"test2", 10})
    Topviews.add_pageview(pid, {"test3", 3})

    expected = [
      {"test3", 3},
      {"test1", 5},
      {"test2", 10}
    ]

    assert(expected == Topviews.get_top(pid))
  end

  test "store lines using size limit", _state do
    {:ok, pid} = Topviews.start(15)
    on_exit(fn -> Agent.stop(pid) end)

    Enum.each(1..25, fn i ->
      Topviews.add_pageview(pid, {"test#{i}", i})
    end)

    expected = [
      {"test11", 11},
      {"test12", 12},
      {"test13", 13},
      {"test14", 14},
      {"test15", 15},
      {"test16", 16},
      {"test17", 17},
      {"test18", 18},
      {"test19", 19},
      {"test20", 20},
      {"test21", 21},
      {"test22", 22},
      {"test23", 23},
      {"test24", 24},
      {"test25", 25}
    ]

    assert(length(expected) == 15)
    assert(expected == Topviews.get_top(pid))
  end
end
