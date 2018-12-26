defmodule Clisaurus.CLI do
  @thesaurus_url "https://www.thesaurus.com/browse/"
  @max_results 20

  def main(args \\ []) do
    args
    |> fetch_data
    |> retrieve_synonyms
    |> IO.puts()
  end

  defp parse_args({_, word, _}) do
    List.to_string(word)
  end

  defp fetch_data(word) do
    case HTTPoison.get(url(word)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body

      # TODO: Handle redirection https://github.com/edgurgel/httpoison/issues/90#issuecomment-153897977
      {:ok, %HTTPoison.Response{status_code: 301}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  defp retrieve_synonyms(html) do
    html
    |> Floki.find(".synonyms-container a")
    |> Enum.take(@max_results)
    |> Floki.text(sep: "\n")
  end

  defp url(word) do
    "#{@thesaurus_url}#{word}"
  end
end
