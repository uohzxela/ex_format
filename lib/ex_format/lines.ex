defmodule ExFormat.Lines do
  def initialize_lines_store(code_string) do
    lines = String.split(code_string, "\n")
    Agent.start_link(fn -> %{} end, name: :lines)
    for {line, i} <- Enum.with_index(lines) do
      update_line(i + 1, String.trim(line))
    end
   # start_link(code_string)
  end

  def start_link(code_string) do
    lines_map =
      code_string
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.map(fn {line, i} ->
        {i + 1, String.trim(line)}
      end)
      |> Map.new
    IO.inspect lines_map
    Agent.start_link(fn -> lines_map end, name: :lines)
  end

  def get_line(k), do: Agent.get(:lines, fn map -> Map.get(map, k) end)

  def update_line(k, v), do: Agent.update(:lines, fn map -> Map.put(map, k, v) end)

  def clear_line(k), do: Agent.update(:lines, fn map -> Map.put(map, k, nil) end)
end
