defmodule Pageviews.FileReader do
  def run do
    IO.puts("Starting run...")
    empty_space = :binary.compile_pattern(" ")

    {:ok, pid} = GenStage.start_link(Pageviews.Genstage_Wiki, :ok)

    final_list =
      Flow.from_stages([pid], max_demand: 100_000)
      |> Flow.map(&String.split(&1, empty_space))
      |> Flow.map(&page_view_pair/1)
      |> Flow.reject(&(&1 == nil))
      |> Flow.partition()
      |> Flow.reduce(
        fn -> %{} end,
        &pageview_update/2
      )
      |> Enum.to_list()

    IO.inspect(length(final_list), label: "ENUM SIZE")
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
    Map.update(acc, page, views, &(&1 + views))
  end
end
