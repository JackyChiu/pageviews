defmodule Pageviews.Wiki do
  @base_url "https://dumps.wikimedia.org/other/pageviews"

  def stream() do
    date = Date.utc_today() |> Date.add(-1)
    time = Time.utc_now()

    Stream.resource(
      fn -> start_func(date, time.hour) end,
      &next_func(&1),
      &close_func(&1)
    )
  end

  def start_func(date, hour) do
    {year, month, day} = pad_date_fields(date)
    hour = pad_hour(hour)
    IO.puts("getting file for date: #{date} hour: #{hour}")
    path = file_path(year, month, day, hour)
    IO.inspect(self(), label: "STREAMING TO")
    HTTPoison.get!(@base_url <> path, [], stream_to: self())

    zstream = :zlib.open()
    :zlib.inflateInit(zstream, 31)

    zstream
  end

  def next_func(zstream) do
    receive_request(zstream)
  end

  def close_func(zstream) do
    :zlib.inflateEnd(zstream)
    :zlib.close(zstream)
  end

  def request_file(processor_id, date, hour) do
    {year, month, day} = pad_date_fields(date)
    hour = pad_hour(hour)
    IO.puts("getting file for date: #{date} hour: #{hour}")
    path = file_path(year, month, day, hour)
    HTTPoison.get!(@base_url <> path, [], stream_to: self())

    zstream = :zlib.open()
    :zlib.inflateInit(zstream, 31)

    receive_request(processor_id: processor_id, zstream: zstream)

    :zlib.inflateEnd(zstream)
    :zlib.close(zstream)
  end

  def receive_request(zstream) do
    IO.inspect(self(), label: "READING FROM")

    receive do
      %HTTPoison.AsyncStatus{code: code} when code != 200 ->
        IO.puts("REQ ERROR #{code}")
        {:error}

      %HTTPoison.AsyncEnd{} ->
        IO.puts("REQ END")
        {:error}

      %HTTPoison.AsyncChunk{chunk: chunk} ->
        inflate_chunk(zstream, :zlib.safeInflate(zstream, chunk), [])

      _ ->
        receive_request(zstream)
    end
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

  defp pad_hour(num) do
    num
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  defp pad_date_fields(date) do
    date
    |> Date.to_string()
    |> String.split("-")
    |> Enum.to_list()
    |> List.to_tuple()
  end

  defp file_path(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pageviews-#{year}#{month}#{day}-#{hour}0000.gz"
  end
end
