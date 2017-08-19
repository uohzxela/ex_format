defmodule Mix.Tasks.Format do
  use Mix.Task

  @shortdoc "Formats Elixir source code"

  def run(file_paths) do
    Enum.each(file_paths, fn file_path ->
      format_file(file_path)
      Mix.shell().info("Formatted #{file_path}")
    end)
  end

  def format_file(file_path) do
    formatted =
      file_path
      |> File.read!()
      |> ExFormat.format()
    File.write!(file_path, formatted)
  end
end
