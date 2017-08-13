import Kernel, except: [to_string: 1]
import ExFormat.Comments

defmodule ExFormat.AST do
  def initialize_ast(string) do
    {_, ast} = Code.string_to_quoted(string, wrap_literals_in_blocks: true)
    ast
  end

  def preprocess({ast, state}) do
    {ast, {_, state}} =
      Macro.prewalk(ast, {[line: 1], state}, fn ast, {prev_meta, state} ->
        {ast, state} =
          handle_zero_arity_fun(ast)
          |> handle_parenless_call(state)
        handle_accumulator(ast, prev_meta, state)
      end)
    {ast, state}
  end

  defp handle_accumulator({sym, curr_meta, args} = ast, prev_meta, state) do
    if curr_meta != [] and prev_meta != [] do
      new_meta = update_meta(curr_meta, prev_meta)
      {{sym, new_meta, args}, {new_meta, state}}
    else
      {ast, {prev_meta, state}}
    end
  end

  defp handle_accumulator(ast, prev_meta, state) do
    {ast, {prev_meta, state}}
  end

  def update_meta(curr_meta) do
    curr_lineno = curr_meta[:line]
    # TODO: is suffix_newline necessary?
    [{:suffix_comments, get_suffix_comments(curr_lineno + 1)}] ++
      curr_meta
  end

  def update_meta(curr_meta, prev_meta) do
    curr_lineno = curr_meta[:line]
    prev_lineno = prev_meta[:line]

    [{:prev, prev_lineno}] ++
      [{:prefix_comments, get_prefix_comments(curr_lineno - 1, prev_lineno)}] ++
      [{:prefix_newline, get_prefix_newline(curr_lineno - 1, prev_lineno)}] ++
      curr_meta
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
