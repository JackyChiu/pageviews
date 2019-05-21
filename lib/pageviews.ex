defmodule Pageviews do
  alias Pageviews.Topviews

  def run do
    IO.puts("Starting run...")

    empty_space = :binary.compile_pattern(" ")
    {:ok, agent_pid} = Topviews.start()

    Flow.from_specs([Pageviews.Wiki], max_demand: 50_000)
    |> Flow.map(&String.split(&1, empty_space))
    |> Flow.map(&pageview_pair/1)
    |> Flow.reject(&(&1 == nil))
    |> Flow.partition()
    |> Flow.reduce(
      fn -> %{} end,
      &pageview_update/2
    )
    |> Flow.each(fn kv_pair ->
      Topviews.add_line(agent_pid, kv_pair)
    end)
    |> Flow.run()

    IO.inspect(Topviews.get_top(agent_pid), label: "TOP")
  end

  def pageview_pair(line) do
    with page when not is_nil(page) <- Enum.at(line, 1),
         views_str when not is_nil(views_str) <- Enum.at(line, 2),
         {views, _} <- Integer.parse(views_str) do
      {page, views}
    else
      _ -> nil
    end
  end

  def pageview_update({page, views}, acc) do
    Map.update(acc, page, views, &(&1 + views))
  end
end
