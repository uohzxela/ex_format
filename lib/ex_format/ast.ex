defmodule ExFormat.AST do
  @moduledoc false

  alias ExFormat.Comments

  def initialize_ast(string) do
    Code.string_to_quoted!(string, wrap_literals_in_blocks: true)
  end

  def preprocess({ast, state}) do
    {ast, {_, state}} =
      Macro.prewalk(ast, {[line: 1], state}, fn ast, {prev_meta, state} ->
        {ast, state} =
          ast
          |> handle_zero_arity_fun()
          |> handle_parenless_call(state)
        handle_accumulator(ast, prev_meta, state)
      end)
    {ast, state}
  end

  defp handle_accumulator({sym, curr_meta, args} = ast, prev_meta, state) do
    if curr_meta != [] and prev_meta != [] do
      {new_meta, new_state} = update_meta(curr_meta, prev_meta, state)
      {{sym, new_meta, args}, {new_meta, new_state}}
    else
      {ast, {prev_meta, state}}
    end
  end

  defp handle_accumulator(ast, prev_meta, state) do
    {ast, {prev_meta, state}}
  end

  def update_meta(curr_meta, state) when curr_meta == [] do
    {curr_meta, state}
  end

  def update_meta(curr_meta, state) do
    curr_lineno = curr_meta[:line]
    # TODO: is suffix_newline necessary?
    {suffix_comments, new_state} = Comments.get_suffix_comments(curr_lineno + 1, state)
    new_meta = [{:suffix_comments, suffix_comments}] ++ curr_meta
    {new_meta, new_state}
  end

  def update_meta(curr_meta, prev_meta, state) do
    curr_lineno = curr_meta[:line]
    prev_lineno = prev_meta[:line]
    {prefix_comments, new_state} = Comments.get_prefix_comments(curr_lineno - 1, prev_lineno, state)
    prefix_newline = Comments.get_prefix_newline(curr_lineno - 1, prev_lineno, new_state)
    new_meta =
      [{:prev, prev_lineno}] ++
      [{:prefix_comments, prefix_comments}] ++
      [{:prefix_newline, prefix_newline}] ++
      curr_meta
    {new_meta, new_state}
  end

  @defs [:def, :defp, :defmacro, :defmacrop, :defdelegate]
  defp handle_zero_arity_fun({sym, meta1, [{fun, meta2, nil} | rest]}) when sym in @defs do
    {sym, meta1, [{fun, meta2, []} | rest]}
  end
  defp handle_zero_arity_fun({:|>, meta1, [left, {fun, meta2, nil}]}) do
    {:|>, meta1, [left, {fun, meta2, []}]}
  end
  defp handle_zero_arity_fun(ast), do: ast

  defp handle_parenless_call({sym, _, list} = ast, state) when is_list(list) do
    {_, last} = :elixir_utils.split_last(list)
    state =
      if Keyword.keyword?(last) and Keyword.has_key?(last, :do) do
        %{state | parenless_calls: MapSet.put(state.parenless_calls, sym)}
      else
        state
      end
    {ast, state}
  end
  defp handle_parenless_call(ast, state), do: {ast, state}
end
