defmodule Pageviews.Application do
  use Application

  def start(_type, _args) do
    # Pageviews.FileReader.run()
    {:ok, self()}
  end
end
