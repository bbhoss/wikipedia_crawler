defmodule Mix.Tasks.Read do
  use Mix.Task

  @shortdoc "Reads a cached Wikipedia URL"
  def run([url]) do
    # TODO: configuration
    riak_bucket = "wikipedia_content"
    {:ok, riak} = Riak.Connection.start_link()
    object = Riak.find(riak, riak_bucket, url)
    if object do
      IO.puts(object.data)
    else
      IO.puts("Object not found")
    end
  end
end
