defmodule Pageviews.Wiki do
  use GenStage
  alias Pageviews.WikiRequest

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(_) do
    date = Date.utc_today() |> Date.add(-1)
    hour = Time.utc_now().hour

    # Start streaming results to current procress.
    WikiRequest.get(self(), date, hour)

    zstream = :zlib.open()
    :zlib.inflateInit(zstream, 31)

    {:producer, {zstream, [], 0, false}}
  end

  def handle_demand(demand, {zstream, lines, remaining_demand, done}) do
    remaining_demand = remaining_demand + demand
    {events, lines} = Enum.split(lines, remaining_demand)

    cond do
      done and length(lines) == 0 ->
        IO.puts("GenStage dieing #{length(lines)}")
        {:stop, :shutdown, {zstream, lines, remaining_demand, done}}

      true ->
        remaining_demand = remaining_demand - length(events)
        # IO.puts("EMITTING #{length(events)} events")
        {:noreply, events, {zstream, lines, remaining_demand, done}}
    end
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, {zstream, lines, remaining_demand, _done}) do
    {new_lines, zstream} = inflate_chunk(zstream, :zlib.safeInflate(zstream, chunk), [])
    lines = Enum.concat(lines, new_lines)

    {events, lines} = Enum.split(lines, remaining_demand)
    remaining_demand = max(remaining_demand - length(events), 0)
    {:noreply, events, {zstream, lines, remaining_demand, false}}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, {zstream, lines, remaining_demand, _done}) do
    IO.puts("DONE DOWNLOADING")
    :zlib.inflateEnd(zstream)
    :zlib.close(zstream)

    {events, lines} = Enum.split(lines, remaining_demand)
    remaining_demand = remaining_demand - length(events)

    cond do
      length(events) > 0 ->
        {:noreply, events, {zstream, lines, remaining_demand, true}}

      true ->
        IO.puts("GenStage dieing #{length(lines)}")
        {:stop, :shutdown, {zstream, lines, remaining_demand, true}}
    end
  end

  def handle_info(_msg, state) do
    {:noreply, [], state}
  end

  defp inflate_chunk(zstream, chunk, acc_lines \\ [])

  # Inflates the chunk of data incrementally until there is no more data.
  defp inflate_chunk(zstream, {:continue, raw_lines}, acc_lines) do
    lines = read_lines(raw_lines)
    inflate_chunk(zstream, :zlib.safeInflate(zstream, []), acc_lines ++ lines)
  end

  defp inflate_chunk(zstream, {:finished, raw_lines}, acc_lines) do
    {zstream, acc_lines ++ read_lines(raw_lines)}
  end

  defp read_lines(lines) do
    lines
    |> Enum.flat_map(&String.split(&1, "\n"))
  end
end
