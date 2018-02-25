defmodule Pageviews.Wiki do
  @base_url "https://dumps.wikimedia.org/other/pageviews"

  def request_file(year, month, day, hour) do
    path = file_path(year, month, day, hour)
    IO.puts("file path: #{path}")
    HTTPoison.get!(@base_url <> path, [], stream_to: self())

    zstream = :zlib.open()
    :zlib.inflateInit(zstream, 31)

    receive_request(zstream)

    :zlib.inflateEnd(zstream)
    :zlib.close(zstream)
  end

  def receive_request(zstream) do
    receive do
      %HTTPoison.AsyncStatus{code: code} when code != 200 ->
        IO.puts("REQ ERROR #{code}")

      %HTTPoison.AsyncEnd{} ->
        IO.puts("REQ END")

      %HTTPoison.AsyncChunk{chunk: chunk} ->
        inflate_chunk(zstream, :zlib.safeInflate(zstream, chunk))
        receive_request(zstream)

      _ ->
        receive_request(zstream)
    end
  end

  def inflate_chunk(zstream, {:continue, lines}) do
    read_lines(lines)
    inflate_chunk(zstream, :zlib.safeInflate(zstream, []))
  end

  def inflate_chunk(zstream, {:finished, lines}) do
    read_lines(lines)
  end

  def read_lines(lines) do
    lines
    |> Enum.map(&String.split(&1, "\n"))
    |> IO.inspect(label: "lines")
  end

  defp file_path(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pageviews-#{year}#{month}#{day}-#{hour}0000.gz"
  end
end
