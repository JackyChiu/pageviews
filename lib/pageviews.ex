defmodule Pageviews do
  def process_top_pages(date, hour) do
    {:ok, agent_id} = Pageviews.Topviews.start()

    pid =
      spawn(fn ->
        process_lines_loop(parent_id: self(), agent_id: agent_id)
      end)

    Pageviews.Wiki.request_file(pid, date, hour)
    wait_for_top()
  end

  def process_lines_loop(opts) do
    receive do
      {:ok, lines} ->
        process_lines(opts, lines)
        process_lines_loop(opts)

      :end ->
        top = Pageviews.Topviews.get_top(opts[:agent_id])
        send(opts[:parent_id], top)
    end
  end

  def process_lines(opts, lines) do
    lines
    |> IO.inspect(label: "lines")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.each(fn line ->
      {page, views} = {Enum.at(line, 1), Enum.at(line, 2)}
      Pageviews.Topviews.add_line(opts[:agent_id], {page, views})
    end)
  end

  def wait_for_top() do
    receive do
      top -> top |> IO.inspect(label: "top")
    end
  end
end
