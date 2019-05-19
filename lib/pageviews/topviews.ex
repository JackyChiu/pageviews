defmodule Pageviews.Topviews do
  use Agent
  alias Pageviews.Insertion

  def start() do
    Agent.start(fn -> [] end)
  end

  def add_line(pid, {page, views}) do
    Agent.update(pid, fn topviews ->
      with true <- length(topviews) >= 25,
           [{_, lowest_topview} | tail] <- topviews do
        if lowest_topview < views do
          [{page, views} | tail]
          |> Insertion.sort(&compare/2)
        else
          topviews
        end
      else
        _ ->
          [{page, views} | topviews]
          |> Insertion.sort(&compare/2)
      end
    end)
  end

  def get_top(pid) do
    Agent.get(pid, & &1)
  end

  defp compare({_, a_views}, {_, b_views}) do
    a_views < b_views
  end
end
