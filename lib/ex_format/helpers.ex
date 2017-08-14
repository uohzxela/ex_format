defmodule ExFormat.Helpers do
  alias ExFormat.Lines

  def get_first_token(lineno) do
    lineno
    |> Lines.get_line()
    |> String.trim_leading()
    |> String.split()
    |> List.first()
  end

  def has_suffix_comments(curr) do
    case Lines.get_line(curr) do
      "#" <> _ ->
        true
      "" ->
        has_suffix_comments(curr + 1)
      _ ->
        false
    end
  end
end
