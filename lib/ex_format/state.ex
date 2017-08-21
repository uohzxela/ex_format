defmodule ExFormat.State do
  @moduledoc false

  alias ExFormat.{
    Comments,
    Lines,
  }

  @parenless_calls [
    :use,
    :import,
    :not,
    :alias,
    :try,
    :raise,
    :reraise,
    :defexception,
    :require,
    :defoverridable,
    :assert,
  ]

  defstruct [
    parenless_calls: MapSet.new(@parenless_calls),
    parenless_zero_arity?: false,
    in_spec: nil,
    last_in_tuple?: false,
    in_assignment?: false,
    in_bin_op?: false,
    in_guard?: false,
    multiline_pipeline?: false,
    multiline_bin_op?: false,
    lines: nil,
    inline_comments: nil,
    context: [],
  ]

  def initialize_state(code_string) do
    %ExFormat.State{
      lines: Lines.initialize_lines_map(code_string),
      inline_comments: Comments.initialize_inline_comments_map(code_string),
    }
  end

  @doc """
  Push an AST symbol into the context stack.
  """
  def push_context(state, ast_sym) do
    %{state | context: [ast_sym | state.context]}
  end

  @doc """
  Peek at the AST symbol at the top of the context stack.
  """
  def prev_context(%ExFormat.State{context: []}) do
    nil
  end

  def prev_context(state) do
    List.first(state.context)
  end
end
