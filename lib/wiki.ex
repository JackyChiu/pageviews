defmodule Pageviews.Wiki do
  @base_url "https://dumps.wikimedia.org/other/pageviews"

  def request_file(year, month, day, hour) do
    path = file_path(year, month, day, hour)
    HTTPoison.get!(@base_url <> path, [], stream_to: self())

    zstream = :zlib.open()
    :zlib.inflateInit(zstream, 31)

    receive_request(zstream)

    :zlib.inflateEnd(zstream)
    :zlib.close(zstream)
  end

  def receive_request(zstream) do
    receive do
      res ->
        handle_async_response(zstream, res)
    end
  end

  def process_chunk(zstream, chunk) do
    {:more, lines} = :zlib.inflateChunk(zstream, chunk)

    lines
    |> Enum.map(&String.split(&1, "\n"))
    |> IO.inspect(label: "split")
  end

  defp handle_async_response(zstream, res) do
    case res do
      %HTTPoison.AsyncStatus{code: code} when code != 200 ->
        IO.puts("REQ ERROR #{code}")

      %HTTPoison.AsyncEnd{} ->
        IO.puts("REQ END")

      %HTTPoison.AsyncChunk{chunk: chunk} ->
        process_chunk(zstream, chunk)
        receive_request(zstream)

      _ ->
        receive_request(zstream)
    end
  end

  defp file_path(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pageviews-#{year}#{month}#{day}-#{hour}0000.gz"
  end
end
