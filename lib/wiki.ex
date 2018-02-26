defmodule Pageviews.Wiki do
  @base_url "https://dumps.wikimedia.org/other/pageviews"

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

  def receive_request(opts) do
    receive do
      %HTTPoison.AsyncStatus{code: code} when code != 200 ->
        IO.puts("REQ ERROR #{code}")
        send(opts[:processor_id], :end)

      %HTTPoison.AsyncEnd{} ->
        IO.puts("REQ END")
        send(opts[:processor_id], :end)

      %HTTPoison.AsyncChunk{chunk: chunk} ->
        zstream = opts[:zstream]
        inflate_chunk(opts, :zlib.safeInflate(zstream, chunk))
        receive_request(opts)

      _ ->
        receive_request(opts)
    end
  end

  def inflate_chunk(opts, {:continue, lines}) do
    lines = read_lines(lines)
    zstream = opts[:zstream]
    send(opts[:processor_id], {:ok, lines})
    inflate_chunk(opts, :zlib.safeInflate(zstream, []))
  end

  def inflate_chunk(opts, {:finished, lines}) do
    lines = read_lines(lines)
    send(opts[:processor_id], {:ok, lines})
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
