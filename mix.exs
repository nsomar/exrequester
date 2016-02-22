defmodule EXRequester.Mixfile do
  use Mix.Project

  def project do
    [app: :exrequester,
    version: "0.0.1",
    elixir: "~> 1.0",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    test_coverage: [tool: Coverex.Task, coveralls: true],
    deps: deps]
  end

  def application do
    [applications: [:logger, :httpotion, :ibrowse]]
  end

  defp deps do
    [{:httpotion, "~> 2.2.0"},
    {:poison, "~> 1.5"},
    {:httpotion, "~> 2.2"},
    {:coverex, "~> 1.4.7", only: :test}]
  end
end
