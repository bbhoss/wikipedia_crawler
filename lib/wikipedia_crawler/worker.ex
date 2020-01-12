defmodule WikipediaCrawler.Worker do
  use GenServer
  use AMQP
  require Logger
  @crawl_queue "crawl_queue"
  @redis_bloom_filter_key "crawled"
  @riak_bucket "wikipedia_content"

  def start_link(arg), do: GenServer.start_link(__MODULE__, arg)
  def init(_arg) do
    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    {:ok, _queue} = Queue.declare(channel, @crawl_queue)
    :ok = Basic.qos(channel, prefetch_count: 1)
    {:ok, _consumer_tag} = Basic.consume(channel, @crawl_queue)
    {:ok, redis} = Redix.start_link()
    {:ok, riak} = Riak.Connection.start_link()

    {:ok, %{channel: channel, redis: redis, riak: riak}}
  end

  def handle_info({:basic_deliver, url, %{delivery_tag: tag}}, state) do
    if crawled_url?(state.redis, url) do
      Logger.info("Already crawled #{url}, skipping")
      Basic.ack(state.channel, tag)
    else
      {content, relative_paths} = WikipediaCrawler.crawl(url)
      Logger.debug("Fetched #{url}")
      store_content(state.riak, url, content)
      publish_links(state.channel, relative_paths)
      mark_crawled(state.redis, url)

      Basic.ack(state.channel, tag)
    end

    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, _}, state), do: {:noreply, state}

  defp publish_links(channel, relative_paths) do
    for path <- relative_paths, do: Basic.publish(channel, "", @crawl_queue, "https://en.wikipedia.org#{path}")
  end

  defp store_content(riak, url, content) do
    object = Riak.Object.create(bucket: @riak_bucket, key: url, data: content)
    %Riak.Object{} = Riak.put(riak, object)
  end

  defp mark_crawled(redis, url), do: Redix.command(redis, ["BF.ADD", @redis_bloom_filter_key, url])

  defp crawled_url?(redis, url) do
    case Redix.command(redis, ["BF.EXISTS", @redis_bloom_filter_key, url]) do
      {:ok, 1} -> true
      {:ok, 0} -> false
    end
  end

end
