defmodule WikipediaCrawler.MixProject do
  use Mix.Project

  def project do
    [
      app: :wikipedia_crawler,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bloom_filter, "~> 1.0.0"},
      {:amqp, "~> 1.4.0"},
      {:redix, "~> 0.10.4"},
      {:httpoison, "~> 1.6"},
      {:floki, "~> 0.24.0"},
      {:riak, "~> 1.1.6"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
