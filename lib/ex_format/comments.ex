defmodule ExFormat.Comments do
  @moduledoc false

  def initialize_inline_comments_map(code_string) do
    lines = String.split(code_string, "\n")
    Enum.reduce(lines, %{}, fn line, acc ->
      inline_comment_token = extract_inline_comment_token(line)
      if inline_comment_token do
        {_, {_, start_col, _}, inline_comment} = inline_comment_token
        fingerprint = String.slice(line, 0..start_col) |> get_line_fingerprint()
        update_inline_comments(acc, fingerprint, inline_comment)
      else
        acc
      end
    end)
  end

  defp update_inline_comments(inline_comments, k, _v) when k == "" do
    inline_comments
  end

  defp update_inline_comments(inline_comments, k, v) do
    Map.update(inline_comments, k, [v], &(&1 ++ [v]))
  end

  defp get_inline_comments(state, k) do
    case state.inline_comments[k] do
      nil ->
        {"", state}
      [] ->
        {"", state}
      [v | rest] ->
        new_state = put_in(state.inline_comments[k], rest)
        {" " <> String.Chars.to_string(v), new_state}
    end
  end


  defp extract_inline_comment_token(line) do
    {_, _, _, tokens} = :elixir_tokenizer.tokenize(to_charlist(line), 0,
      preserve_comments: true, check_terminators: false)
    token =
      tokens
      |> Stream.with_index()
      |> Stream.filter(fn {token, i} ->
        elem(token, 0) == :comment and
        i > 0 and
        get_lineno(Enum.at(tokens, i - 1)) == get_lineno(token)
      end)
      |> Enum.to_list()
      |> List.first()
    if token, do: elem(token, 0), else: token
  end

  defp get_line_fingerprint(line) do
    # TODO: be less aggressive with removing non-word chars here
    Enum.join(String.split(line, ~r/\W+/))
  end

  defp get_lineno(nil), do: nil
  defp get_lineno(token) do
    {lineno, _, _} = elem(token, 1)
    lineno
  end

  def postprocess(formatted_string, state) do
    formatted_lines = String.split(formatted_string, "\n")
    {postprocessed, _state} =
      Enum.reduce(formatted_lines, {nil, state}, fn line, {acc, state} ->
        line = String.trim_trailing(line)
        fingerprint = get_line_fingerprint(line)
        {inline_comments, new_state} = get_inline_comments(state, fingerprint)
        if acc == nil do
          {line <> inline_comments, new_state}
        else
          {acc <> "\n" <> line <> inline_comments, new_state}
        end
      end)
    postprocessed <> "\n"
  end

  def get_prefix_newline(curr, prev, state) do
    if curr >= prev and state.lines[curr] == "", do: "\n", else: ""
  end

  def get_prefix_comments(curr, prev, state) when curr < prev, do: {"", state}

  def get_prefix_comments(curr, prev, state) do
    case state.lines[curr] do
      "#" <> comment ->
        comment = get_prefix_newline(curr - 1, prev, state) <> "#" <> comment <> "\n"
        state = put_in(state.lines[curr], nil)
        {prefix_comments, state} = get_prefix_comments(curr - 1, prev, state)
        {prefix_comments <> comment, state}
      "" ->
        get_prefix_comments(curr - 1, prev, state)
      _ ->
        {"", state}
    end
  end

  def get_suffix_comments(curr, state) do
    case state.lines[curr] do
      "#" <> comment ->
        comment = "\n" <> get_prefix_newline(curr - 1, 0, state) <> "#" <> comment
        state = put_in(state.lines[curr], nil)
        {suffix_comments, state} = get_suffix_comments(curr + 1, state)
        {comment <> suffix_comments, state}
      "" ->
        get_suffix_comments(curr + 1, state)
      _ ->
        {"", state}
    end
  end
end
