defmodule Pageviews.CLI do
  def main(args) do
    validate_args(args)
  end

  def validate_args(args) do
    if length(args) != 2 do
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

    Pageviews.process_top_pages(date, hour)
  end
end
