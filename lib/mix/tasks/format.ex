defmodule Mix.Tasks.Format do
  use Mix.Task

  alias ExFormat

  @shortdoc "Formats Elixir source code"

  def run(file_paths) do
    Enum.map(file_paths, fn file_path ->
      formatted =
        file_path
        |> File.read!()
        |> ExFormat.format()
      file = File.open!(file_path, [:write])
      IO.binwrite(file, formatted)
      File.close(file)
      IO.puts("Formatted #{file_path}")
    end)
  end
end
