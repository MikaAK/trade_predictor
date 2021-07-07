defmodule AiPredictor.DatasetDownloader do
  @dataset_path "#{:code.priv_dir(:ai_predictor)}/datasets"

  def csv_path(symbol), do: "#{@dataset_path}/#{symbol}.csv"

  def load(symbol, start_year \\ 1995) do
    with {:ok, csv_string} <- load_csv(symbol, start_year),
         :ok <- write_file(csv_path(symbol), csv_string) do
      {:ok, csv_string}
    end
  end

  defp load_csv(symbol, start_year) do
    res = :get
      |> Finch.build(build_url(symbol, start_year))
      |> Finch.request(AiPredictor.Finch)

    case res do
      {:ok, %Finch.Response{body: body, status: 200}} -> {:ok, body}
      {:ok, res} -> {:error, %{code: :internal_server_error, details: res, message: "Unknown error"}}
      {:error, e} -> {:error, %{code: :internal_server_error, details: e, message: "Unknown error"}}
    end
  end

  defp build_url(symbol, start_year) do
    start_period = get_start_period(start_year)
    now = DateTime.to_unix(DateTime.utc_now())

    "https://query1.finance.yahoo.com/v7/finance/download/#{symbol}?period1=#{start_period}&period2=#{now}&interval=1d&events=history&includeAdjustedClose=true"
  end

  defp get_start_period(start_year) do
    start_year
      |> NaiveDateTime.new(1, 1, 0, 0, 0, 0)
      |> elem(1)
      |> DateTime.from_naive!("America/New_York", Tzdata.TimeZoneDatabase)
      |> DateTime.to_unix
  end

  defp write_file(path, contents) do
    with {:error, :enoent} <- File.write(path, contents),
         :ok <- File.mkdir_p(String.replace(path, ~r/[^\/]+$/, "") |> IO.inspect),
         :ok <- File.touch(path) do
      File.write(path, contents)
    end
  end
end
