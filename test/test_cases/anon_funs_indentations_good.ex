defp map_list_to_string(list, fun) do
  list_string =
    Enum.map_join(list, ", ", fn {key, value} ->
      to_string(key, fun) <> " => " <> to_string(value, fun)
    end)
end

fn key ->
  1
  1 + 2
end

fn -> 1 end

fn -> 1 end

fn ->
  1
  1 + 2
end

fn k -> 1 end

fn k ->
  1
end
