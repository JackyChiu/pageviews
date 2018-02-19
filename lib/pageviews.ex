defmodule Pageviews do
  @base_url "https://dumps.wikimedia.org/other/pagecounts-all-sites"

  """
  Pageviews.process_top_pages(~D[2015-01-01], 4)
  """

  def process_top_pages(date, hour) do
    request_file(date, hour)
    stream_request()
  end

  def process_pageview_stream(stream) do
    stream
    |> IO.inspect(label: "process stream called:")

    stream_request()
  end

  def request_file(date, hour) do
    padded_date = split_date_with_pad(date)
    [year, month, day, hour] = padded_date ++ [pad_intger(hour)]

    file_path = file_path(year, month, day, hour)

    {:ok, res} = HTTPoison.get(@base_url <> file_path, [], stream_to: self())
    res
  end

  def stream_request() do
    receive do
      res -> handle_async_response(res)
    end
  end

  defp handle_async_response(res) do
    case res do
      %HTTPoison.AsyncStatus{code: code} when code != 200 ->
        IO.puts("REQ ERROR #{code}")

      %HTTPoison.AsyncEnd{} ->
        IO.puts("REQ END")

      %HTTPoison.AsyncChunk{chunk: data} ->
        process_pageview_stream(data)

      _ ->
        stream_request()
    end
  end

  defp file_path(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pagecounts-#{year}#{month}#{day}-#{hour}0000.gz"
  end

  defp pad_intger(num) do
    num
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  defp split_date_with_pad(date) do
    date
    |> Date.to_string()
    |> String.split("-")
  end
end
