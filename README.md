# WikipediaCrawler

Crawls wikipedia, distributing new URLs to crawl via RabbitMQ. Optimization of URL fetching is done via Redis and [RedisBloom](https://github.com/RedisBloom/RedisBloom).

## Running
Ensure you have Redis with RedisBloom, RabbitMQ, and Riak started on their default ports with default authentication settings.

Then, start the crawler with `mix crawl`. Finally, if you haven't started the crawl process yet, pick your starting URL and run `mix kickoff <URL>` to have the initial message sent to kick off the crawling process. This URL should not have been crawled before.

## Reading
If you'd like to see the HTML crawled from Wikipedia, just run `mix read <URL>`.

## Design
This application is designed so that Elixir (or another service later) does all of the work: making the http request, parsing the HTML, and storing it.

RabbitMQ is utilized for work distribution using the competing consumer pattern, instead of Erlang's native distribution, which was not built to handle scaling up to massive numbers of nodes, or to work on unreliable cloud networking stacks. Each page that is crawled has its links to other articles collected, and after checking to ensure they haven't yet been crawled, the application publishes these messages to be crawled by any worker that subscribes to the queue.

Redis is used to determine if a URL has already been crawled. Since many pages are being crawled in parallel that may contain the same links, there needs to be a central store of what articles have been crawled so we don't waste time making HTTP requests. It's much faster to check before dispatching the links and before crawling than making duplicate requests. While I believe Redis should be able to handle checking set inclusion on 6 million records (total English pages) just fine, I decided to utilize a bloom filter plug in to make this even more efficient. This ensures performance will not degrade as much as the number of crawled articles increases. It's worth testing though to see if RedisBloom is actually necessary, as it is not truly open-source and also complicates deployment, since a custom module needs to be installed.

Finally, Riak is used for content storage. Riak is great for storing medium sized blobs of data indexed on a single key. It has great operational scaling characteristics which would make it much easier to add additional capacity and make this system highly available. At a very basic level it offers CRUD operations on keys, with secondary indices, search, and time series options available if needed. It's a great option for persisting blobs over a network, something like a self-hosted Amazon S3 or Google Cloud Storage. I could have used Redis for this, but Redis is really designed for in-memory storage, not long-term persistence.

## Things I didn't get to

Due to time constraints this is not at the level of quality I'd like. One of the first needs that is unmet is configuration, currently the application only works with services running on localhost with default or no authentication. Configuration options should be provided by Mix Config, with releases built as Docker images ready to be run in a Kubernetes-like system.

Additionally, I'd like to make all of the service dependencies have their own behaviours/contracts so that they become mockable and pluggable in case of changing operation needs or possibilities. It's entirely possible to do all of this with Postgres for example, and without clear contracts it would be difficult to know you are done porting it to Postgres, especially if the complexity had increased over time.

Finally, it would be nice to have it all tested. If the service dependencies had behaviours, it would be as simple as mocking them out and writing a few unit tests. This would make developing changes much faster as you wouldn't need to worry about having other services running or the state that lives in them.