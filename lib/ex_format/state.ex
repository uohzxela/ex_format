defmodule ExFormat.State do
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

  def initialize_state() do
    %{
      parenless_calls: MapSet.new(@parenless_calls),
      parenless_zero_arity?: false,
      in_spec: nil,
      last_in_tuple?: false,
      in_assignment?: false,
      in_bin_op?: false,
      in_guard?: false,
      multiline_pipeline?: false,
      multiline_bin_op?: false,
    }
  end
end