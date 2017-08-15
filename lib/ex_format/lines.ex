defmodule ExFormat.Lines do
  @moduledoc false

  def initialize_lines_map(code_string) do
    code_string
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map(fn {line, i} ->
      {i + 1, String.trim(line)}
    end)
    |> Map.new
  end
end
