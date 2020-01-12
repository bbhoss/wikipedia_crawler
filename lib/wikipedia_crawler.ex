defmodule WikipediaCrawler do
  require IEx

  def crawl(url) do
    # Don't run awry of the rules
    :timer.sleep(1000)

    response = HTTPoison.get!(url)
    {:ok, document} = Floki.parse_document(response.body)

    links =
      for anchor <- Floki.find(document, "a"),
          is_relative_link(anchor),
          do: Floki.attribute(anchor, "href")

    {response.body, links}
  end

  defp is_relative_link([]), do: false

  defp is_relative_link(anchor) do
    case Floki.attribute(anchor, "href") do
      [] -> false
      ["/" <> _bin | _t] -> true
      _ -> false
    end
  end
end
