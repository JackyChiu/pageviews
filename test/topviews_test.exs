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
    :ok = Topviews.add_line(pid, {"hi", 5})
    assert([{"hi", 5}], Topviews.get_top(pid))
  end
end
