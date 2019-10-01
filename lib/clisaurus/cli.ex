defmodule Clisaurus.CLI do
  @thesaurus_url "https://www.thesaurus.com/browse/"
  @max_results 20
  @nav_links ["Thesaurus.com", "Word of the Day", "Crossword Solver", "Everything After Z", "Dictionary.com", "Dictionary.com","Thesaurus.com","definitions", "noun"]

  def main(args \\ []) do
    args
    |> fetch_data
    |> parse_html
    |> IO.puts()
  end

  defp fetch_data(word) do
    case HTTPoison.get(url(word)) do
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 301}} ->
        {:error, "Word '#{word}' is misspelled, please check your input and try again"}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found :("}
    end
  end

  defp parse_html({:error, string}), do: string

  defp parse_html({:ok, string}) do
    nav_link_count = Enum.count(@nav_links)
    
    string
    |> Floki.find("ul:nth-of-type(1) a")
    |> Enum.take(@max_results + nav_link_count)
    |> Enum.drop(nav_link_count)
    |> Floki.text(sep: "\n")
  end

  defp url(word) do
    "#{@thesaurus_url}#{word}"
  end
end
