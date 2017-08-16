defmodule ExFormat.Lines do
  @moduledoc false

  def initialize_lines_map(code_string) do
    lines = String.split(code_string, "\n")
    for {line, index} <- Enum.with_index(lines, _offset = 1),
        into: %{},
        do: {index, String.trim(line)}
  end
end
