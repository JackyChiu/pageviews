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
        loop_inflate(zstream, :zlib.safeInflate(zstream, chunk))
        receive_request(zstream)

      _ ->
        receive_request(zstream)
    end
  end

  def loop_inflate(zstream, {:continue, lines}) do
    handler(lines)
    loop_inflate(zstream, :zlib.safeInflate(zstream, []))
  end

  def loop_inflate(zstream, {:finished, lines}) do
    handler(lines)
  end

  def handler(lines) do
    lines
    |> Enum.map(&String.split(&1, "\n"))
    |> IO.inspect(label: "lines")
  end

  defp file_path(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pageviews-#{year}#{month}#{day}-#{hour}0000.gz"
  end
end
