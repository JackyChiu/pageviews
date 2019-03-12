defmodule Pageviews.FileReader do
  def run do
    IO.puts("hello")

    streams =
      for _ <- File.ls!("./") do
        File.stream!("./pageviews-20190312-180000", read_ahead: 100_000)
      end

    streams
    |> Flow.from_enumerables()
    |> Flow.map(&String.split(&1, " "))
    |> Flow.map(fn line ->
      {views, _} = Enum.at(line, 2) |> Integer.parse()
      {Enum.at(line, 1), views}
    end)
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn {url, views}, acc ->
      Map.update(acc, url, 1, &(&1 + views))
    end)
    |> Enum.to_list()
    |> IO.inspect()
  end
end
