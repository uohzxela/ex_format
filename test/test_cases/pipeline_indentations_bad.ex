1 |> 2 |> 3 |> 4

1
|> 2
|> 3
|> 4


input |> String.strip() |> String.downcase()
String.strip(input) |>
String.downcase()

result = input |> String.trim()

String.strip(input)
|> String.downcase()
|> String.slice(1, 3) # inline comment

args = args_to_string(args, fun) |> # inline comment
String.split("\"") |>
  Enum.drop(-1) # inline comment
|> Enum.join()
