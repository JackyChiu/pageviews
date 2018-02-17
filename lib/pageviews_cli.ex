defmodule Pageviews.CLI do
  def main(args) do
    if length(args) != 2 do
      raise ArgumentError, message: "expected date and hour arguments" 
    end
    { :ok, date } = Date.from_iso8601(args[0])
    { :ok, hour } = Integer.parse(args[1])
    Pageviews.process_top_pages(date, hour) 
  end
end
