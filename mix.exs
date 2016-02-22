defmodule EXRequester.Mixfile do
  use Mix.Project

  def project do
    [app: :exrequester,
    name: "exrequester",
    source_url: "https://github.com/oarrabi/exrequester",
    docs: [ extras: ["README.md"] ],
    description: description,
    version: "0.0.1",
    elixir: "~> 1.0",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    test_coverage: [tool: Coverex.Task, coveralls: true],
    deps: deps,
    package: package]
  end

  def application do
    [applications: [:logger, :httpotion, :ibrowse]]
  end

  defp deps do
    [{:httpotion, "~> 2.2.0"},
    {:poison, "~> 1.5"},
    {:httpotion, "~> 2.2"},
    {:coverex, "~> 1.4.7", only: :test},
    {:inch_ex, only: :docs}]
  end

  defp description do
    """
    Quickly define your API functions using module attributes.
    """
  end

  defp package do
    [ files: [ "lib", "mix.exs", "README.md",],
      maintainers: [ "Omar Abdelhafith" ],
      links: %{ "GitHub" => "https://github.com/oarrabi/exrequester" } ]
  end

end
