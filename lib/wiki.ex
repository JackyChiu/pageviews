defmodule Pageviews.Wiki do
  @base_url "https://dumps.wikimedia.org/other/pagecounts-all-sites"

  def request_file(year, month, day, hour) do
    path = file_path(year, month, day, hour)
    {:ok, _} = HTTPoison.get(@base_url <> path, [], stream_to: self())
    receive_request()
  end

  def receive_request() do
    receive do
      res ->
        handle_async_response(res)
        receive_request()
    end
  end

  def process_chunk(chunk) do
    zip = :zlib.open()
    :zlib.inflateInit(zip, 31)

    chunk
    |> IO.inspect(label: "process chunk called:")

    {_, lines} = :zlib.safeInflate(zip, chunk)

    lines
    |> IO.inspect(label: "inflate")
    |> String.split("\n")
    |> IO.inspect(label: "split")

    :zlib.inflateEnd(zip)
    :zlib.close(zip)
  end

  defp handle_async_response(res) do
    case res do
      %HTTPoison.AsyncStatus{code: code} when code != 200 ->
        IO.puts("REQ ERROR #{code}")

      %HTTPoison.AsyncEnd{} ->
        IO.puts("REQ END")

      %HTTPoison.AsyncChunk{chunk: data} ->
        process_chunk(data)

      _ ->
        nil
    end
  end

  defp file_path(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pagecounts-#{year}#{month}#{day}-#{hour}0000.gz"
  end
end
