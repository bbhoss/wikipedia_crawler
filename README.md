# WikipediaCrawler

Crawls wikipedia, distributing new URLs to crawl via RabbitMQ. Optimization of URL fetching is done via Redis and [RedisBloom](https://github.com/RedisBloom/RedisBloom).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `wikipedia_crawler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wikipedia_crawler, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/wikipedia_crawler](https://hexdocs.pm/wikipedia_crawler).

