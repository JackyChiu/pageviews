defmodule Pageviews do
  @base_url "https://dumps.wikimedia.org/other/pagecounts-all-sites"

  def process_top_pages(date, hour) do
    file = request_file(date, hour)
  end

  def request_file(date, hour) do
    padded_date = split_date_with_pad(date)
    [year, month, day, hour] = padded_date ++ [pad_intger(hour)]

    file_path = build_file_url(year, month, day, hour)

    {:ok, res} = HTTPoison.get(@base_url <> file_path)
    res.body
  end

  def build_file_url(year, month, day, hour) do
    "/#{year}/#{year}-#{month}/pagecounts-#{year}#{month}#{day}-#{hour}0000.gz"
  end

  def pad_intger(num) do
    num
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  def split_date_with_pad(date) do
    date
    |> Date.to_string()
    |> String.split("-")
  end
end
