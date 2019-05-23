defmodule PageviewsTest do
  use ExUnit.Case
  alias Pageviews.Topviews

  setup do
    {:ok, pid} = Topviews.start(3)

    on_exit(fn -> Agent.stop(pid) end)

    {:ok, pid: pid}
  end

  test "accumulate_and_filter accumulates inputs", state do
    agent_pid = state[:pid]

    Flow.from_enumerable([
      {"a_page", 6},
      {"c_page", 3},
      {"a_page", 5},
      {"b_page", 10},
      {"b_page", 1},
      {"to be kicked", 0},
      {"b_page", 1},
      {"a_page", 2},
      {"c_page", 4}
    ])
    |> Pageviews.accumulate_and_filter(agent_pid)
    |> Flow.run()

    expected = [
      {"c_page", 7},
      {"b_page", 12},
      {"a_page", 13}
    ]

    assert expected == Topviews.get_top(agent_pid)
  end

  test "accumulate_and_filter blacklists", state do
    agent_pid = state[:pid]

    Flow.from_enumerable([
      {"Main_Page", 6},
      {"Not blacklisted", 5}
    ])
    |> Pageviews.accumulate_and_filter(agent_pid)
    |> Flow.run()

    expected = [{"Not blacklisted", 5}]
    assert expected == Topviews.get_top(agent_pid)
  end
end
