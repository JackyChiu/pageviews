defmodule Pageviews.Topviews do
  use Agent

  def start() do
    Agent.start(fn -> [] end)
  end

  def add_line(pid, {page, views}) do
    Agent.update(pid, fn topviews ->
      cond do
        Enum.count(topviews) >= 25 ->
          topviews =
            cond do
              Enum.at(topviews, -1)[:views] < views ->
                topviews |> Enum.drop(-1)

              true ->
                topviews
            end

          (topviews ++ [%{page: page, views: views}])
          |> IO.inspect(label: "topviews")
          |> Enum.sort(&compare/2)

        true ->
          topviews ++ [%{page: page, views: views}]
      end
    end)
  end

  def get_top(pid) do
    Agent.get(pid, fn topviews -> topviews end)
  end

  defp compare(a, b) do
    cond do
      a[:views] == b[:views] -> a[:page] >= b[:page]
      true -> a[:views] > b[:views]
    end
  end
end
