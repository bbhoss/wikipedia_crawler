defmodule WikipediaCrawlerTest do
  use ExUnit.Case
  doctest WikipediaCrawler

  test "greets the world" do
    assert WikipediaCrawler.hello() == :world
  end
end
