defmodule WikipediaCrawler.Worker do
  use GenServer
  use AMQP
  require Logger
  @crawl_queue "crawl_queue"

  def start_link(arg), do: GenServer.start_link(__MODULE__, arg)
  def init(_arg) do
    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    {:ok, _queue} = Queue.declare(channel, @crawl_queue)
    :ok = Basic.qos(channel, prefetch_count: 1)
    {:ok, _consumer_tag} = Basic.consume(channel, @crawl_queue)
    {:ok, redis} = Redix.start_link()

    {:ok, %{channel: channel, redis: redis}}
  end

  def handle_info(msg = {:basic_deliver, url, %{delivery_tag: tag}}, state) do
    case Redix.command(state.redis, ["BF.EXISTS", "crawled", url]) do
      {:ok, 1} ->
        Logger.info("Already crawled #{url}, skipping")
        Basic.ack(state.channel, tag)
      {:ok, 0} ->
        {content, urls} = WikipediaCrawler.crawl(url)
        Logger.debug("Fetched #{url}")
        Redix.command(state.redis, ["BF.ADD", "crawled", url])
        Basic.ack(state.channel, tag)
    end

    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, _}, state), do: {:noreply, state}
end
