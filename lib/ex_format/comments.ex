defmodule ExFormat.Comments do
  @moduledoc """
  Module for comment handling in preprocessing and postprocessing phases.
  """

  @doc """
  Returns a map storing inline comments from the given code string.

  For each line in the given code string, it extracts the inline comment using `:elixir_tokenizer.tokenize/3` function.
  After the inline comment is extracted, it is stored in the map.
  The key is the current line's fingerprint and the value is a list of inline comments.

  Example:
  ```
  some_function_call(arg1, arg2) # comment1
  some_function_call(arg1, arg2) # comment2
  ```

  In this context, the key would be `some_function_callarg1arg2` (line fingerprint with all non-word characters stripped)
  and the value would be `["comment1", "comment2"]`.

  The inline comments are added to a list with insertion order maintained
  since we can have multiple inline comments for the same line fingerprint.

  Whenever we retrieve an inline comment during postprocessing phase, it is removed from the list.
  """
  def initialize_inline_comments_map(code_string) do
    lines = String.split(code_string, "\n")
    Enum.reduce(lines, %{}, fn line, acc ->
      inline_comment_token = extract_inline_comment_token(line)
      if inline_comment_token do
        {_, {_, start_col, _}, inline_comment} = inline_comment_token
        fingerprint =
          line
          |> String.slice(0..start_col)
          |> get_line_fingerprint()
        update_inline_comments(acc, fingerprint, inline_comment)
      else
        acc
      end
    end)
  end

  # Insert new inline comment in the map, appending it to the list.
  defp update_inline_comments(inline_comments, k, _v) when k == "" do
    inline_comments
  end

  defp update_inline_comments(inline_comments, k, v) do
    Map.update(inline_comments, k, [v], &(&1 ++ [v]))
  end

  # Get inline comments given the line fingerprint. Remove it from the list if found.
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

  # Extract inline comment from the given line.
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
  rescue
    _ ->
      nil
  end

  # Strip all non-word chars to get the fingerprint of the line.
  defp get_line_fingerprint(line) do
    # TODO: be less aggressive with removing non-word chars here
    Enum.join(String.split(line, ~r/\W+/))
  end

  # Get the line number from the token returned by the Elixir tokenizer.
  defp get_lineno(nil), do: nil
  defp get_lineno(token) do
    {lineno, _, _} = elem(token, 1)
    lineno
  end

  @doc """
  Augument formatted code with inline comments and remaining comments after the last line of code.
  """
  def postprocess({formatted_string, state}) do
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
    postprocessed <> "\n" <> get_remaining_comments(state)
  end

  # Get remaining comments after the last line of code
  defp get_remaining_comments(state) do
    lines_of_code =
      state.lines
      |> Enum.sort()
      |> Enum.map(&elem(&1, 1))

    # last line of code index
    last_loc_index =
      lines_of_code
      |> Enum.reverse()
      |> Enum.find_index(fn x ->
        case x do
          "#" <> _ ->
            false
          "" ->
            false
          _ ->
            true
        end
      end)

    last_loc_index = if last_loc_index, do: last_loc_index, else: 1

    remaining_comments =
      lines_of_code
      |> Enum.slice(length(lines_of_code) - last_loc_index..-1)
      |> Enum.map_join("\n", &(&1))

    if remaining_comments != "" do
      String.trim_trailing(remaining_comments) <> "\n"
    else
      remaining_comments
    end
  end

  @doc """
  Retrieves line break between the current line number and previous line number.

  If there are multiple line breaks, return only one.

  Returns a newline character if found, otherwise an empty string.
  """
  def get_prefix_newline(curr, prev, state) do
    if curr >= prev and state.lines[curr] == "", do: "\n", else: ""
  end

  @doc """
  Retrieves comments between the current line number and previous line number.

  Returns a group of comments separated by newline if found, otherwise an empty string.
  """
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

  @doc """
  Retrieves comments after the current line number.

  It keeps collecting comments until it hits the next line of code.

  Returns a group of comments separated by newline if found, otherwise an empty string.
  """
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
