defmodule Pageviews.FileReader do
  def run do
    IO.puts("Starting run...")

    Pageviews.Wiki.stream()
    |> Flow.from_enumerable()
    |> Flow.map(&String.split(&1, " "))
    |> Flow.map(&page_view_pair/1)
    |> Flow.reject(&(&1 == nil))
    |> Flow.reduce(
      fn -> %{} end,
      &pageview_update/2
    )
    |> Enum.to_list()
    |> IO.inspect()
  end

  def page_view_pair(line) do
    with views_str when not is_nil(views_str) <- Enum.at(line, 2),
         {views, _} <- Integer.parse(views_str) do
      {Enum.at(line, 1), views}
    else
      _ -> nil
    end
  end

  def pageview_update({page, views}, acc) do
    Map.update(acc, page, 1, &(&1 + views))
  end
end
