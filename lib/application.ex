defmodule Pageviews.Application do
  use Application

  def start(_type, _args) do
    Pageviews.run()
    {:ok, self()}
  end
end
