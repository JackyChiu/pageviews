defmodule Pageviews.Topviews do
  use Agent

  def start(size_limit \\ 10) do
    Agent.start(fn -> {size_limit, []} end)
  end

  def add_pageview(pid, {page, views}) do
    Agent.update(pid, fn {size_limit, topviews} ->
      topviews = insert(size_limit, topviews, {page, views})
      {size_limit, topviews}
    end)
  end

  def get_top(pid) do
    Agent.get(pid, fn {_size_limit, topviews} -> topviews end)
  end

  defp insert(size_limit, topviews, {page, views}) when length(topviews) < size_limit do
    [{page, views} | topviews]
    |> Enum.sort(&compare/2)
  end

  defp insert(_size_limit, topviews, {page, views}) do
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
