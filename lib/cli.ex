defmodule Formatter.CLI do
  @moduledoc """
  Usage ./formatter [path/to/file]
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                                     aliases: [ h: :help])

    case parse do
      { [ help: true ], _, _ } -> :help
      { _, argv, _ } -> argv
    end
  end

  @doc """
  Displays a help message.
  """
  def process(:help) do
    IO.puts @moduledoc
    System.halt(0)
  end

  def process(argv) do
    if length(argv) == 1 do
      Formatter.process List.first(argv)
    else
      IO.puts "Please input one argument."
      System.halt(0)
    end
  end
end