defmodule Pageviews.WikiRequest do
  @base_url "https://dumps.wikimedia.org/other/pageviews"

  # Streams the chunks of data recieved from the request to the provided pid.
  def get(pid, date, hour) do
    {year, month, day} = pad_date_fields(date)
    hour = pad_hour(hour)
    IO.puts("getting file for date: #{date} hour: #{hour}")
    path = file_path(year, month, day, hour)
    HTTPoison.get!(@base_url <> path, [], stream_to: pid)
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
