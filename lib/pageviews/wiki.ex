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

  # Handles demand for the pageview lines requested by the consumer.
  def handle_demand(demand, {zstream, lines, remaining_demand, done}) do
    emit({zstream, lines, remaining_demand + demand, done})
  end

  # Handles chunks of data streaming in from the HTTP request.
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, {zstream, lines, remaining_demand, _done}) do
    {zstream, new_lines} = inflate_chunk(zstream, :zlib.safeInflate(zstream, chunk))
    emit({zstream, lines ++ new_lines, remaining_demand, false})
  end

  # Handles the end of the HTTP request's stream.
  def handle_info(%HTTPoison.AsyncEnd{}, {zstream, lines, remaining_demand, _done}) do
    IO.puts("HTTP REQUEST DONE STREAMING")
    :zlib.inflateEnd(zstream)
    :zlib.close(zstream)

    emit({zstream, lines, remaining_demand, true})
  end

  def handle_info(_msg, state) do
    {:noreply, [], state}
  end

  # Emits as much events as the remaining_demand requests for.
  # Stops once the stream is finished and there are no more leftover
  # events.
  defp emit({zstream, lines, remaining_demand, done}) do
    {lines, leftover} = Enum.split(lines, remaining_demand)
    remaining_demand = remaining_demand - length(lines)

    cond do
      done and length(leftover) == 0 ->
        {:stop, :shutdown, {zstream, leftover, remaining_demand, done}}

      true ->
        {:noreply, lines, {zstream, leftover, remaining_demand, done}}
    end
  end

  # Inflates the chunk of data incrementally.
  defp inflate_chunk(zstream, chunk, acc_lines \\ [])

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
