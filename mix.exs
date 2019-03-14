defmodule Pageviews.MixProject do
  use Mix.Project

  def project do
    [
      app: :pageviews,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pageviews.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:flow, "~> 0.14"}
    ]
  end

  defp escript do
    [
      main_module: Pageviews.CLI,
      path: "bin/pageviews"
    ]
  end
end
