defmodule Pageviews.Genstage_Wiki do
  @base_url "https://dumps.wikimedia.org/other/pageviews"
  use GenStage

  def init(_) do
    date = Date.utc_today() |> Date.add(-1)
    time = Time.utc_now()
    hour = time.hour

    {year, month, day} = pad_date_fields(date)
    hour = pad_hour(hour)
    IO.puts("getting file for date: #{date} hour: #{hour}")
    path = file_path(year, month, day, hour)
    IO.inspect(self(), label: "STREAMING TO")
    HTTPoison.get!(@base_url <> path, [], stream_to: self())

    zstream = :zlib.open()
    :zlib.inflateInit(zstream, 31)

    {:producer, {zstream, [], false}}
  end

  def handle_demand(demand, {zstream, lines, done}) do
    {ret, lines} = Enum.split(lines, demand)

    cond do
      done and length(lines) == 0 ->
        IO.puts("GenStage dieing #{length(lines)}")
        {:stop, :shutdown, {zstream, lines, done}}

      true ->
        IO.puts("remaining #{length(lines)}")
        {:noreply, ret, {zstream, lines, done}}
    end
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, {zstream, lines, _done}) do
    {new_lines, zstream} = inflate_chunk(zstream, :zlib.safeInflate(zstream, chunk), [])
    {:noreply, [], {zstream, lines ++ new_lines, false}}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, {zstream, lines, _done}) do
    IO.puts("DONE DOWNLOADING")
    :zlib.inflateEnd(zstream)
    :zlib.close(zstream)
    {:noreply, [], {zstream, lines, true}}
  end

  def handle_info(_, state) do
    {:noreply, [], state}
  end

  def inflate_chunk(zstream, {:continue, lines}, acc_lines) do
    lines = read_lines(lines)
    inflate_chunk(zstream, :zlib.safeInflate(zstream, []), acc_lines ++ lines)
  end

  def inflate_chunk(zstream, {:finished, lines}, acc_lines) do
    {acc_lines ++ read_lines(lines), zstream}
  end

  def read_lines(lines) do
    lines
    |> Enum.flat_map(&String.split(&1, "\n"))
  end

  defp pad_date_fields(date) do
    date
    |> Date.to_string()
    |> String.split("-")
    |> Enum.to_list()
    |> List.to_tuple()
  end

  defp pad_hour(num) do
    num
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  defp file_path(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pageviews-#{year}#{month}#{day}-#{hour}0000.gz"
  end
end
