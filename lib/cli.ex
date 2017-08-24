defmodule ExFormat.CLI do
  @moduledoc """
  Example usage: `./ex_format lib/**/*.ex config/**/*.exs`
  """

  def main(argv) do
    argv
    |> parse_args()
    |> run()
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])

    case parse do
      {[help: true], _, _} ->
        :help
      {_, argv, _} ->
        argv
    end
  end

  @doc """
  Displays a help message.
  """
  def run(:help) do
    IO.puts(@moduledoc)
  end

  @doc """
  Formats a list of files.
  """
  def run(file_paths) do
    Enum.each(file_paths, fn file_path ->
      IO.write("Formatting #{file_path} ... ")
      Mix.Tasks.Format.format_file(file_path)
      IO.puts("done.")
    end)
  end
end
