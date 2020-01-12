defmodule Mix.Tasks.Crawl do
  use Mix.Task

  @shortdoc "Consumes URLs to crawl"
  def run(_) do
    Application.ensure_all_started(:wikipedia_crawler, :permanent)

    children = [
      WikipediaCrawler.Worker
    ]

    opts = [strategy: :one_for_one, name: WikipediaCrawler.Supervisor]
    Supervisor.start_link(children, opts)
    :timer.sleep(:infinity)
  end
end
