defmodule Pageviews.CLI do
  def main(args) do
    try do
      {date, hour} = validate_args(args)
      Pageviews.process_top_pages(date, hour)
    rescue
      e in ArgumentError -> e
    end
  end

  def validate_args(args) do
    unless length(args) == 2 do
      raise ArgumentError, message: "expected date and hour arguments"
    end

    {:ok, date} =
      args
      |> Enum.at(0)
      |> Date.from_iso8601()

    {hour, _} =
      args
      |> Enum.at(1)
      |> Integer.parse()

    {date, hour}
  end
end
