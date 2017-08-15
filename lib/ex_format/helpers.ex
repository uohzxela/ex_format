defmodule ExFormat.Helpers do
  @moduledoc false

  def get_first_token(lineno, state) do
    state.lines[lineno]
    |> String.trim_leading()
    |> String.split()
    |> List.first()
  end

  def has_suffix_comments(curr, state) do
    case state.lines[curr] do
      "#" <> _ ->
        true
      "" ->
        has_suffix_comments(curr + 1, state)
      _ ->
        false
    end
  end
end
