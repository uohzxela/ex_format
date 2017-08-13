defmodule ExFormat.Lines do
  def initialize_lines_store(string) do
  	lines = String.split(string, "\n")
    Agent.start_link(fn -> %{} end, name: :lines)
    for {line, i} <- Enum.with_index(lines) do
      update_line(i + 1, String.trim(line))
    end
  end

  def get_line(k), do: Agent.get(:lines, fn map -> Map.get(map, k) end)

  def update_line(k, v), do: Agent.update(:lines, fn map -> Map.put(map, k, v) end)

  def clear_line(k), do: Agent.update(:lines, fn map -> Map.put(map, k, nil) end)
end