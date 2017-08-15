defmodule ExFormat.Comments do
  @moduledoc false

  def initialize_inline_comments_store(code_string) do
    start_link(code_string)
  end

  def start_link(code_string) do
    lines = String.split(code_string, "\n")
    Agent.start_link(fn -> %{} end, name: :inline_comments)
    for {line, _i} <- Enum.with_index(lines) do
      inline_comment_token = extract_inline_comment_token(line)

      if inline_comment_token do
        {_, {_, start_col, _}, inline_comment} = inline_comment_token
        fingerprint =
          line
          |> String.slice(0..start_col)
          |> get_line_fingerprint()
        if fingerprint != "", do: update_inline_comments(fingerprint, inline_comment)
      end
    end
  end

  def update_inline_comments(k, v) do
    Agent.update(:inline_comments, fn map ->
      if Map.has_key?(map, k) do
        val = Map.get(map, k)
        Map.put(map, k, val ++ [v])
      else
        Map.put(map, k, [v])
      end
    end)
  end

  def get_inline_comments(k) do
    vals = Agent.get(:inline_comments, fn map -> Map.get(map, k) end)
    case vals do
      nil ->
        ""
      [] ->
        ""
      [v | rest] ->
        Agent.update(:inline_comments, fn map -> Map.put(map, k, rest) end)
        " " <> String.Chars.to_string(v)
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

  def get_lineno(nil), do: nil
  def get_lineno(token) do
    {lineno, _, _} = elem(token, 1)
    lineno
  end

  def postprocess(formatted) do
    formatted_lines = String.split(formatted, "\n")
    formatted =
      Enum.map_join(formatted_lines, "\n", fn line ->
        line = String.trim_trailing(line)
        fingerprint = get_line_fingerprint(line)
        line <> get_inline_comments(fingerprint)
      end)
    formatted <> "\n"
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
