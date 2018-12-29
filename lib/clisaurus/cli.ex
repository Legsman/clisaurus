defmodule Clisaurus.CLI do
  @thesaurus_url "https://www.thesaurus.com/browse/"
  @max_results 20

  def main(args \\ []) do
    args
    |> fetch_data
    |> parse_html
    |> IO.puts()
  end

  defp fetch_data(word) do
    case HTTPoison.get(url(word)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 301}} ->
        {:error, "Word '#{word}' is misspelled, please check your input and try again"}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found :("}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp parse_html({:error, string}), do: string

  defp parse_html({:ok, string}) do
    string
    |> Floki.find(".synonyms-container a")
    |> Enum.take(@max_results)
    |> Floki.text(sep: "\n")
  end

  defp url(word) do
    "#{@thesaurus_url}#{word}"
  end
end
