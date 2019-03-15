defmodule Pageviews.Topviews do
  use Agent

  def start() do
    Agent.start(fn -> [] end)
  end

  def add_line(pid, {page, views}) do
    Agent.update(pid, fn topviews ->
      [{_, lowest_topview} | tail] = topviews

      topviews =
        cond do
          length(topviews) >= 25 and lowest_topview < views -> tail
          true -> topviews
        end

      [{page, views} | topviews]
      |> Enum.sort(&compare/2)
    end)
  end

  def get_top(pid) do
    Agent.get(pid, & &1)
  end

  defp compare({a_page, a_views}, {b_page, b_views}) do
    cond do
      a_views == b_views -> a_page >= b_page
      true -> a_views > b_views
    end
  end
end
