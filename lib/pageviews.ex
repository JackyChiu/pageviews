defmodule Pageviews do
  require Logger
  alias Pageviews.Topviews

  def run do
    Logger.info("Starting run...")

    {:ok, agent_pid} = Topviews.start(25)

    Flow.from_specs([Pageviews.Wiki], max_demand: 50_000)
    |> create_pairs
    |> Flow.partition()
    |> accumulate_and_filter(agent_pid)
    |> Flow.run()

    IO.inspect(Topviews.get_top(agent_pid), label: "TOP")
  end

  def create_pairs(flow) do
    empty_space = :binary.compile_pattern(" ")

    flow
    |> Flow.map(&String.split(&1, empty_space))
    |> Flow.map(&pageview_pair/1)
    |> Flow.reject(&(&1 == nil))
  end

  defp pageview_pair(line) do
    with page when not is_nil(page) <- Enum.at(line, 1),
         views_str when not is_nil(views_str) <- Enum.at(line, 2),
         {views, _} <- Integer.parse(views_str) do
      {page, views}
    else
      _ -> nil
    end
  end

  def accumulate_and_filter(flow, agent_pid) do
    flow
    |> Flow.reject(&in_blacklist/1)
    |> Flow.reduce(
      fn -> %{} end,
      &pageview_update/2
    )
    |> Flow.each(fn kv_pair ->
      Topviews.add_pageview(agent_pid, kv_pair)
    end)
  end

  defp in_blacklist({page, _view}) do
    page in [
      "Special:CreateAccount",
      "Special:Search",
      "Special:BlankPage",
      "Main_Page",
      "-"
    ]
  end

  defp pageview_update({page, views}, acc) do
    Map.update(acc, page, views, &(&1 + views))
  end
end
