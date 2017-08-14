defmodule ExFormat.Lines do
  def initialize_lines_store(code_string) do
   start_link(code_string)
  end

  def start_link(code_string) do
    Agent.start_link(fn -> %{} end, name: :lines)
    lines_map =
      code_string
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.map(fn {line, i} ->
        {i + 1, String.trim(line)}
      end)
      |> Map.new

    Agent.update(:lines, &Map.merge(&1, lines_map))
  end

  def get_line(k), do: Agent.get(:lines, &Map.get(&1, k))

  def clear_line(k), do: Agent.update(:lines, &Map.put(&1, k, nil))
end
