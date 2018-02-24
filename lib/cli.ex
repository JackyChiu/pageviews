defmodule Pageviews.CLI do
  def main(args) do
    run(args)
  end

  def run(args) do
    {date, hour} = parse_args(args)
    Pageviews.process_top_pages(date, hour)
  end

  def parse_args([]) do
    date = Date.utc_today()
    time = Time.utc_now() |> Time.add(-1 * 60 * 60, :second)
    {date, time.hour}
  end

  def parse_args([date, hour]) do
    {:ok, date} = Date.from_iso8601(date)
    {hour, _} = Integer.parse(hour)
    {date, hour}
  end
end
