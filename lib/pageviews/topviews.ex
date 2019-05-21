defmodule Pageviews.Topviews do
  use Agent

  def start() do
    Agent.start(fn -> [] end)
  end

  def add_line(pid, {page, views}) do
    Agent.update(pid, fn topviews ->
      insert({page, views}, topviews)
    end)
  end

  def get_top(pid) do
    Agent.get(pid, & &1)
  end

  defp insert({page, views}, topviews) when length(topviews) < 25 do
    [{page, views} | topviews]
    |> Enum.sort(&compare/2)
  end

  defp insert({page, views}, topviews) do
    with [{_, lowest_view} | tail] <- topviews,
         true <- lowest_view < views do
      [{page, views} | tail]
      |> Enum.sort(&compare/2)
    else
      _ -> topviews
    end
  end

  defp compare({_, a_views}, {_, b_views}) do
    a_views < b_views
  end
end
