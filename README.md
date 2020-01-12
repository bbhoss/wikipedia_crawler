# WikipediaCrawler

Crawls wikipedia, distributing new URLs to crawl via RabbitMQ. Optimization of URL fetching is done via Redis and [RedisBloom](https://github.com/RedisBloom/RedisBloom).

## Running
Ensure you have Redis with RedisBloom, RabbitMQ, and Riak started on their default ports with default authentication settings.

Then, start the crawler with `mix crawl`. Finally, if you haven't started the crawl process yet, pick your starting URL and run `mix kickoff <URL>` to have the initial message sent to kick off the crawling process. This URL should not have been crawled before.

## Reading
If you'd like to see the HTML crawled from Wikipedia, just run `mix read <URL>`.