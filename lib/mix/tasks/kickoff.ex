defmodule Mix.Tasks.Kickoff do
  use Mix.Task
  use AMQP

  @shortdoc "Kicks off the crawl process with a URL of your choice"
  def run([url]) do
    # TODO: configuration
    crawl_queue = "crawl_queue"

    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    {:ok, _queue} = Queue.declare(channel, crawl_queue)

    Basic.publish(channel, "", crawl_queue, url)
  end
end
