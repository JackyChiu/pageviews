defmodule Pageviews do
  def process_top_pages(date, hour) do
    request_file(date, hour)
  end

  def request_file(date, hour) do
    IO.puts(date)
    IO.puts(hour)
    IO.puts "hello"
  end
end
