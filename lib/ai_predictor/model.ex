defmodule AiPredictor.Model do
  @default_opts [
    path: "#{:code.priv_dir(:ai_predictor)}/python",
    python: 'python3'
  ]

  def start_link(opts \\ []) do
    opts = @default_opts |> Keyword.merge(opts) |> Keyword.update!(:path, &to_charlist/1)

    :python.start(python_path: opts[:path], python: 'python3')
  end

  def predict_tomorrows_close(pid \\ @default_opts[:name], symbol) do
    :python.call(pid, :arima_model, :predict, [symbol])
  end
end
