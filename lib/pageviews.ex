defmodule Pageviews do
  """
  Pageviews.process_top_pages(~D[2018-01-01], 4)
  """

  def process_top_pages(date, hour) do
    {year, month, day} = pad_date_fields(date)
    hour = pad_hour(hour)
    IO.puts("getting file for date: #{date} hour: #{hour}")
    Pageviews.Wiki.request_file(year, month, day, hour)
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
end
