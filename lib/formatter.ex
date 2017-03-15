import Kernel, except: [to_string: 1]

defmodule Formatter do
  @typedoc "Abstract Syntax Tree (AST)"
  @type t :: expr | {t, t} | atom | number | binary | pid | fun | [t]
  @type expr :: {expr | atom, Keyword.t, atom | [t]}

  @binary_ops [:===, :!==,
    :==, :!=, :<=, :>=,
    :&&, :||, :<>, :++, :--, :\\, :::, :<-, :.., :|>, :=~,
    :<, :>, :->,
    :+, :-, :*, :/, :=, :|, :.,
    :and, :or, :when, :in,
    :~>>, :<<~, :~>, :<~, :<~>, :<|>,
    :<<<, :>>>, :|||, :&&&, :^^^, :~~~]

  @doc false
  defmacro binary_ops, do: @binary_ops

  @unary_ops [:!, :@, :^, :not, :+, :-, :~~~, :&]

  @doc false
  defmacro unary_ops, do: @unary_ops

  @spec binary_op_props(atom) :: {:left | :right, precedence :: integer}
  defp binary_op_props(o) do
    case o do
      o when o in [:<-, :\\]                  -> {:left,  40}
      :when                                   -> {:right, 50}
      :::                                     -> {:right, 60}
      :|                                      -> {:right, 70}
      :=                                      -> {:right, 90}
      o when o in [:||, :|||, :or]            -> {:left, 130}
      o when o in [:&&, :&&&, :and]           -> {:left, 140}
      o when o in [:==, :!=, :=~, :===, :!==] -> {:left, 150}
      o when o in [:<, :<=, :>=, :>]          -> {:left, 160}
      o when o in [:|>, :<<<, :>>>, :<~, :~>,
                :<<~, :~>>, :<~>, :<|>, :^^^] -> {:left, 170}
      :in                                     -> {:left, 180}
      o when o in [:++, :--, :.., :<>]        -> {:right, 200}
      o when o in [:+, :-]                    -> {:left, 210}
      o when o in [:*, :/]                    -> {:left, 220}
      :.                                      -> {:left, 310}
    end
  end

  def process(file_name) do
    file_content = File.read!(file_name)
    lines = String.split(file_content, "\n")
    Agent.start_link(fn -> %{} end, name: :lines)
    Agent.start_link(fn -> %{} end, name: :comments)
    for {s, i} <- Enum.with_index(lines) do
      s = String.trim(s)
      update_line(i+1, s)
      if String.first(s) == "#" do
        Agent.update(:comments, fn map ->
          Map.put(map, i+1, String.slice(s, 1, String.length(s)))
        end)
      end
    end
    # TODO: use a lexer to retrieve comments from file_content to handle inline comments
    {_, ast} = Code.string_to_quoted(file_content)
    {ast, _prev_ctx} = preprocess(ast)
    # TODO: display remaining comments if any, after last accessed line
    IO.inspect ast
    IO.puts "\n"
    IO.puts to_string(ast, fn ast, string ->
      case is_tuple(ast) and tuple_size(ast) == 3 do
        true ->
          {_, ctx, _} = ast
          Enum.join [ctx[:comments], ctx[:new_line], string]
        false -> string
      end
    end)
  end

  defp preprocess(ast) do
    Macro.prewalk(ast, [line: 1], fn ast, prev_ctx ->
      # TODO: insert lineno in kw_list AST node e.g. [do: {...}]
      case is_tuple(ast) and tuple_size(ast) == 3 do
        true ->
          {sym, curr_ctx, args} = ast
          if prev_ctx != [] and curr_ctx != [] do
            {{sym, update_context(curr_ctx, prev_ctx), args}, curr_ctx}
          else
            {ast, prev_ctx}
          end
        false ->
          {ast, prev_ctx}
      end
    end)
  end

  defp update_context(curr_ctx, prev_ctx) do
    curr_lineno = curr_ctx[:line]
    prev_lineno = prev_ctx[:line]

    curr_ctx = [{:prev, prev_lineno} | curr_ctx]
    curr_ctx = [{:comments, get_comments(curr_lineno-1, prev_lineno)} | curr_ctx]
    [{:new_line, get_newline(curr_lineno-1, prev_lineno)} | curr_ctx]
  end

  defp get_line(k), do: Agent.get(:lines, fn map -> Map.get(map, k) end)
  defp update_line(k, v), do: Agent.update(:lines, fn map -> Map.put(map, k, v) end)
  defp clear_line(k), do: Agent.update(:lines, fn map -> Map.put(map, k, nil) end)

  defp get_newline(curr, prev) when curr < prev, do: ""
  defp get_newline(curr, prev), do: get_newline(curr-1, prev, get_line(curr))
  defp get_newline(_curr, _prev, ""), do: "\n"
  defp get_newline(_curr, _prev, _), do: ""

  defp get_comments(curr, prev) when curr < prev, do: ""
  defp get_comments(curr, prev), do: get_comments(curr, prev, get_line(curr))
  defp get_comments(curr, prev, "#" <> s) do
    s = get_newline(curr-1, prev) <> "# " <> String.trim_leading(s) <> "\n"
    clear_line(curr)
    get_comments(curr-1, prev, get_line(curr-1)) <> s
  end
  defp get_comments(curr, prev, _) when curr < prev, do: ""
  defp get_comments(curr, prev, ""), do: get_comments(curr-1, prev, get_line(curr-1))
  defp get_comments(_curr, _prev, _), do: ""
  
  defp multiline?({:__block__, _, _} = _ast), do: true
  defp multiline?({_, ctx, _} = _ast), do: ctx != [] and ctx[:line] > ctx[:prev]
  defp multiline?(_ast), do: false

  defp get_first_token(nil), do: ""
  defp get_first_token(line) do
    line
    |> String.trim_leading
    |> String.split
    |> List.first
  end

  @doc """
  Converts the given expression to a binary.
  The given `fun` is called for every node in the AST with two arguments: the
  AST of the node being printed and the string representation of that same
  node. The return value of this function is used as the final string
  representation for that AST node.
  ## Examples
      iex> Macro.to_string(quote(do: foo.bar(1, 2, 3)))
      "foo.bar(1, 2, 3)"
      iex> Macro.to_string(quote(do: 1 + 2), fn
      ...>   1, _string -> "one"
      ...>   2, _string -> "two"
      ...>   _ast, string -> string
      ...> end)
      "one + two"
  """
  @spec to_string(Macro.t) :: String.t
  @spec to_string(Macro.t, (Macro.t, String.t -> String.t)) :: String.t
  def to_string(tree, fun \\ fn(_ast, string) -> string end)

  # Variables
  def to_string({var, _, atom} = ast, fun) when is_atom(atom) do
    fun.(ast, Atom.to_string(var))
  end

  # Aliases
  def to_string({:__aliases__, _, refs} = ast, fun) do
    fun.(ast, Enum.map_join(refs, ".", &call_to_string(&1, fun)))
  end

  # Blocks
  def to_string({:__block__, _, [expr]} = ast, fun) do
    fun.(ast, to_string(expr, fun))
  end

  def to_string({:__block__, _, _} = ast, fun) do
    fun.(ast, block_to_string(ast, fun))
  end

  # Bits containers
  def to_string({:<<>>, _, parts} = ast, fun) do
    if interpolated?(ast) do
      fun.(ast, interpolate(ast, fun))
    else
      result = Enum.map_join(parts, ", ", fn(part) ->
        str = bitpart_to_string(part, fun)
        if :binary.first(str) == ?< or :binary.last(str) == ?> do
          "(" <> str <> ")"
        else
          str
        end
      end)
      fun.(ast, "<<" <> result <> ">>")
    end
  end

  # Tuple containers
  def to_string({:{}, _, args} = ast, fun) do
    tuple = "{" <> Enum.map_join(args, ", ", &to_string(&1, fun)) <> "}"
    fun.(ast, tuple)
  end

  # Map containers
  def to_string({:%{}, _, args} = ast, fun) do
    map = "%{" <> map_to_string(args, fun) <> "}"
    fun.(ast, map)
  end

  def to_string({:%, _, [structname, map]} = ast, fun) do
    {:%{}, _, args} = map
    struct = "%" <> to_string(structname, fun) <> "{" <> map_to_string(args, fun) <> "}"
    fun.(ast, struct)
  end

  # Fn keyword
  def to_string({:fn, _, [{:->, _, [_, tuple]}] = arrow} = ast, fun)
      when not is_tuple(tuple) or elem(tuple, 0) != :__block__ do
    fun.(ast, "fn " <> arrow_to_string(arrow, fun) <> " end")
  end

  def to_string({:fn, _, [{:->, _, _}] = block} = ast, fun) do
    fun.(ast, "fn " <> block_to_string(block, fun) <> "\nend")
  end

  def to_string({:fn, _, block} = ast, fun) do
    block = adjust_new_lines block_to_string(block, fun), "\n  "
    fun.(ast, "fn\n  " <> block <> "\nend")
  end

  # Ranges
  def to_string({:.., _, args} = ast, fun) do
    range = Enum.map_join(args, "..", &to_string(&1, fun))
    fun.(ast, range)
  end

  # left -> right
  def to_string([{:->, _, _} | _] = ast, fun) do
    fun.(ast, "(" <> arrow_to_string(ast, fun, true) <> ")")
  end

  # left when right
  def to_string({:when, ctx, [left, right]} = ast, fun) do
    # IO.puts ":::::::::left when right::::::::::::::"
    right =
      if right != [] and Keyword.keyword?(right) do
        kw_list_to_string(right, fun)
      else
        fun.(right, op_to_string(right, fun, :when, :right))
      end

    {padding, newline} =
      case multiline?(ast) do
        true ->
          token = get_first_token(get_line ctx[:prev])
          {Enum.join(for _ <- 0..String.length(token), do: " "), "\n"}
        false ->
          {" ", ""}
      end
    # IO.puts op_to_string(left, fun, :when, :left)
    # IO.puts right
    op_to_string(left, fun, :when, :left) <> newline <> fun.(ast, "#{padding}when " <> right)
  end

  # Binary ops
  def to_string({op, _, [left, right]} = ast, fun) when op in unquote(@binary_ops) do
    # TODO: check for multi-line expr, then indent by two spaces if necessary (adjust_new_lines/2)
    fun.(ast, op_to_string(left, fun, op, :left) <> " #{op} " <> op_to_string(right, fun, op, :right))
  end

  # Splat when
  def to_string({:when, _, args} = ast, fun) do
    # IO.puts "::::::::::splat when:::::::::::"
    {left, right} = :elixir_utils.split_last(args)
    fun.(ast, "(" <> Enum.map_join(left, ", ", &to_string(&1, fun)) <> ") when " <> to_string(right, fun))
  end

  # Capture
  def to_string({:&, _, [{:/, _, [{name, _, ctx}, arity]}]} = ast, fun)
      when is_atom(name) and is_atom(ctx) and is_integer(arity) do
    fun.(ast, "&" <> Atom.to_string(name) <> "/" <> to_string(arity, fun))
  end

  def to_string({:&, _, [{:/, _, [{{:., _, [mod, name]}, _, []}, arity]}]} = ast, fun)
      when is_atom(name) and is_integer(arity) do
    fun.(ast, "&" <> to_string(mod, fun) <> "." <> Atom.to_string(name) <> "/" <> to_string(arity, fun))
  end

  def to_string({:&, _, [arg]} = ast, fun) when not is_integer(arg) do
    fun.(ast, "&(" <> to_string(arg, fun) <> ")")
  end

  # Unary ops
  def to_string({unary, _, [{binary, _, [_, _]} = arg]} = ast, fun)
      when unary in unquote(@unary_ops) and binary in unquote(@binary_ops) do
    fun.(ast, Atom.to_string(unary) <> "(" <> to_string(arg, fun) <> ")")
  end

  def to_string({:not, _, [arg]} = ast, fun)  do
    fun.(ast, "not " <> to_string(arg, fun))
  end

  def to_string({op, _, [arg]} = ast, fun) when op in unquote(@unary_ops) do
    fun.(ast, Atom.to_string(op) <> to_string(arg, fun))
  end

  # Access
  def to_string({{:., _, [Access, :get]}, _, [{op, _, _} = left, right]} = ast, fun)
      when op in unquote(@binary_ops) do
    fun.(ast, "(" <> to_string(left, fun) <> ")" <> to_string([right], fun))
  end

  def to_string({{:., _, [Access, :get]}, _, [left, right]} = ast, fun) do
    fun.(ast, to_string(left, fun) <> to_string([right], fun))
  end

  # All other calls
  def to_string({target, _, args} = ast, fun) when is_list(args) do
    if sigil = sigil_call(ast, fun) do
      sigil
    else
      {list, last} = :elixir_utils.split_last(args)
      fun.(ast, case kw_blocks?(last) do
        true  -> call_to_string_with_args(target, list, fun) <> kw_blocks_to_string(last, fun)
        false -> call_to_string_with_args(target, args, fun)
      end)
    end
  end

  # Two-element tuples
  def to_string({left, right}, fun) do
    to_string({:{}, [], [left, right]}, fun)
  end

  # Lists
  def to_string(list, fun) when is_list(list) do
    fun.(list, cond do
      list == [] ->
        "[]"
      :io_lib.printable_list(list) ->
        IO.iodata_to_binary [?', Inspect.BitString.escape(IO.chardata_to_string(list), ?'), ?']
      Inspect.List.keyword?(list) ->
        "[" <> kw_list_to_string(list, fun) <> "]"
      true ->
        "[" <> Enum.map_join(list, ", ", &to_string(&1, fun)) <> "]"
    end)
  end

  # All other structures
  def to_string(other, fun), do: fun.(other, inspect(other, []))

  defp bitpart_to_string({:::, _, [left, right]} = ast, fun) do
    result =
      op_to_string(left, fun, :::, :left) <>
      "::" <>
      bitmods_to_string(right, fun, :::, :right)
    fun.(ast, result)
  end

  defp bitpart_to_string(ast, fun) do
    to_string(ast, fun)
  end

  defp bitmods_to_string({op, _, [left, right]} = ast, fun, _, _) when op in [:*, :-] do
    result =
      bitmods_to_string(left, fun, op, :left) <>
      Atom.to_string(op) <>
      bitmods_to_string(right, fun, op, :right)
    fun.(ast, result)
  end

  defp bitmods_to_string(other, fun, parent_op, side) do
    op_to_string(other, fun, parent_op, side)
  end

  # Block keywords
  @kw_keywords [:do, :catch, :rescue, :after, :else]

  defp kw_blocks?([{:do, _} | _] = kw) do
    Enum.all?(kw, &match?({x, _} when x in unquote(@kw_keywords), &1))
  end
  defp kw_blocks?(_), do: false

  # Check if we have an interpolated string.
  defp interpolated?({:<<>>, _, [_ | _] = parts}) do
    Enum.all?(parts, fn
      {:::, _, [{{:., _, [Kernel, :to_string]}, _, [_]},
                {:binary, _, _}]} -> true
      binary when is_binary(binary) -> true
      _ -> false
    end)
  end

  defp interpolated?(_) do
    false
  end

  defp interpolate({:<<>>, _, parts}, fun) do
    parts = Enum.map_join(parts, "", fn
      {:::, _, [{{:., _, [Kernel, :to_string]}, _, [arg]}, {:binary, _, _}]} ->
        "\#{" <> to_string(arg, fun) <> "}"
      binary when is_binary(binary) ->
        binary = inspect(binary, [])
        :binary.part(binary, 1, byte_size(binary) - 2)
    end)

    <<?", parts::binary, ?">>
  end

  defp module_to_string(atom, _fun) when is_atom(atom), do: inspect(atom, [])
  defp module_to_string(other, fun), do: call_to_string(other, fun)

  defp sigil_call({func, _, [{:<<>>, _, _} = bin, args]} = ast, fun) when is_atom(func) and is_list(args) do
    sigil =
      case Atom.to_string(func) do
        <<"sigil_", name>> ->
          "~" <> <<name>> <>
          interpolate(bin, fun) <>
          sigil_args(args, fun)
        _ ->
          nil
      end
    fun.(ast, sigil)
  end

  defp sigil_call(_other, _fun) do
    nil
  end

  defp sigil_args([], _fun),   do: ""
  defp sigil_args(args, fun), do: fun.(args, List.to_string(args))

  # for 'def', function names etc.
  defp call_to_string(atom, _fun) when is_atom(atom),
    do: Atom.to_string(atom)
  defp call_to_string({:., _, [{:&, _, [val]} = arg]}, fun) when not is_integer(val),
    do: "(" <> module_to_string(arg, fun) <> ")."
  defp call_to_string({:., _, [{:fn, _, _} = arg]}, fun),
    do: "(" <> module_to_string(arg, fun) <> ")."
  defp call_to_string({:., _, [arg]}, fun),
    do: module_to_string(arg, fun) <> "."
  # e.g. env.module()
  defp call_to_string({:., _, [left, right]}, fun),
    do: module_to_string(left, fun) <> "." <> call_to_string(right, fun)
  defp call_to_string(other, fun),
    do: to_string(other, fun)


  defp call_to_string_with_args(target, args, fun) do
    need_parens = not target in [:def]
    target = call_to_string(target, fun)
    args = args_to_string(args, fun)
    if need_parens do
      target <> "(" <> args <> ")"
    else
      target <> " " <> args
    end
  end

  # turn (a, b, c) into strings
  defp args_to_string(args, fun) do
    {list, last} = :elixir_utils.split_last(args)
    if last != [] and Inspect.List.keyword?(last) do
      prefix =
        case list do
          [] -> ""
          _  -> Enum.map_join(list, ", ", &to_string(&1, fun)) <> ", "
        end
      prefix <> kw_list_to_string(last, fun)
    else
      Enum.map_join(args, ", ", &to_string(&1, fun))
    end
  end

  defp kw_blocks_to_string(kw, fun) do
    {s, multiline?} = Enum.reduce(@kw_keywords, {"", false}, fn(x, acc) ->
      if Keyword.has_key?(kw, x) do
        ast = Keyword.get(kw, x)
        {s, multiline?} = acc
        multiline? = multiline? or multiline?(ast)
        s = s <> kw_block_to_string(x, ast, fun, multiline?)
        {s, multiline?}
      else
        acc
      end
    end)
    if multiline?, do: " " <> s <> "end", else: s
  end

  # print do ... end
  defp kw_block_to_string(key, value, fun, multiline?) do
    # indent lines in block
    block = block_to_string(value, fun)
    if multiline? do
      block = adjust_new_lines block, "\n  "
      Atom.to_string(key) <> "\n  " <> block <> "\n"
    else
      ", " <> Atom.to_string(key) <> ": " <> block
    end
  end

  defp block_to_string([{:->, _, _} | _] = block, fun) do
    Enum.map_join(block, "\n", fn({:->, _, [left, right]}) ->
      left = comma_join_or_empty_paren(left, fun, false)
      left <> "->\n  " <> adjust_new_lines block_to_string(right, fun), "\n  "
    end)
  end

  defp block_to_string({:__block__, _, exprs}, fun) do
    Enum.map_join(exprs, "\n", &to_string(&1, fun))
  end

  defp block_to_string(other, fun), do: to_string(other, fun)

  defp map_to_string([{:|, _, [update_map, update_args]}], fun) do
    to_string(update_map, fun) <> " | " <> map_to_string(update_args, fun)
  end

  defp map_to_string(list, fun) do
    cond do
      Inspect.List.keyword?(list) -> kw_list_to_string(list, fun)
      true -> map_list_to_string(list, fun)
    end
  end

  defp kw_list_to_string(list, fun) do
    Enum.map_join(list, ", ", fn {key, value} ->
      atom_name = case Inspect.Atom.inspect(key) do
        ":" <> rest -> rest
        other       -> other
      end
      atom_name <> ": " <> to_string(value, fun)
    end)
  end

  defp map_list_to_string(list, fun) do
    Enum.map_join(list, ", ", fn {key, value} ->
      to_string(key, fun) <> " => " <> to_string(value, fun)
    end)
  end

  defp parenthise(expr, fun) do
    "(" <> to_string(expr, fun) <> ")"
  end

  defp op_to_string({op, _, [_, _]} = expr, fun, parent_op, side) when op in unquote(@binary_ops) do
    {parent_assoc, parent_prec} = binary_op_props(parent_op)
    {_, prec}                   = binary_op_props(op)
    cond do
      parent_prec < prec -> to_string(expr, fun)
      parent_prec > prec -> parenthise(expr, fun)
      true ->
        # parent_prec == prec, so look at associativity.
        if parent_assoc == side do
          to_string(expr, fun)
        else
          parenthise(expr, fun)
        end
    end
  end

  defp op_to_string(expr, fun, _, _), do: to_string(expr, fun)

  defp arrow_to_string(pairs, fun, paren \\ false) do
    Enum.map_join(pairs, "; ", fn({:->, _, [left, right]}) ->
      left = comma_join_or_empty_paren(left, fun, paren)
      left <> "-> " <> to_string(right, fun)
    end)
  end

  defp comma_join_or_empty_paren([], _fun, true),  do: "() "
  defp comma_join_or_empty_paren([], _fun, false), do: ""

  defp comma_join_or_empty_paren(left, fun, _) do
    Enum.map_join(left, ", ", &to_string(&1, fun)) <> " "
  end

  defp adjust_new_lines(block, replacement) do
    for <<x <- block>>, into: "" do
      case x == ?\n do
        true  -> replacement
        false -> <<x>>
      end
    end
  end
end
