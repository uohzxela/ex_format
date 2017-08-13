import Kernel, except: [to_string: 1]
import ExFormat.Lines

defmodule ExFormat.Helpers do
  def get_first_token(lineno) do
    lineno
    |> get_line()
    |> String.trim_leading()
    |> String.split()
    |> List.first()
  end

  def has_suffix_comments(curr) do
    case get_line(curr) do
      "#" <> _ ->
        true
      "" ->
        has_suffix_comments(curr + 1)
      _ ->
        false
    end
  end
end
