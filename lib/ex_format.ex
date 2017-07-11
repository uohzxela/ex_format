import Kernel, except: [to_string: 1]

defmodule ExFormat do
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

  @line_limit 120

  def process(file_name) do
    file_name
    |> File.read!
    |> prepare_data
    |> preprocess
    |> format
    |> postprocess
  end

  defp format(ast) do
    to_string(ast, fn ast, string ->
      case ast do
        # {:__block__, ctx, [nil]} ->
        #   String.trim ctx[:suffix_comments]
        {_, meta, _} ->
          Enum.join [meta[:prefix_comments], meta[:prefix_newline], string, meta[:suffix_comments]]
        _ ->
          string
      end
    end)
  end

  defp prepare_data(file_content) do
    lines = String.split(file_content, "\n")
    Agent.start_link(fn -> %{} end, name: :lines)
    Agent.start_link(fn -> %{} end, name: :inline_comments)
    for {line, i} <- Enum.with_index(lines) do
      update_line(i+1, String.trim(line))
      inline_comment_token = extract_inline_comment_token(line)

      if inline_comment_token do
        {_, {_, start_col, _}, inline_comment} = inline_comment_token
        fingerprint = line
        |> String.slice(0..start_col)
        |> get_line_fingerprint
        if fingerprint != "", do: update_inline_comments(fingerprint, inline_comment)
      end
    end
    {_, ast} = Code.string_to_quoted(file_content, wrap_literals_in_blocks: true)
    ast
  end

  defp postprocess(formatted) do
    formatted_lines = String.split(formatted, "\n")
    formatted = Enum.map_join(formatted_lines, "\n", fn line ->
      line = String.trim_trailing line
      fingerprint = get_line_fingerprint line
      line <> get_inline_comments(fingerprint)
    end)
    IO.puts formatted
    formatted <> "\n"
  end

  defp extract_inline_comment_token(line) do
    {_, _, _, tokens} = :elixir_tokenizer.tokenize(to_charlist(line), 0,
      preserve_comments: true, check_terminators: false)
    token = tokens
    |> Stream.with_index
    |> Stream.filter(fn {token, i} ->
      elem(token, 0) == :comment and i > 0 and get_lineno(Enum.at(tokens, i-1)) == get_lineno(token)
    end)
    |> Enum.to_list
    |> List.first
    if token, do: elem(token, 0), else: token
  end

  defp get_line_fingerprint(line) do
    # TODO: be less aggressive with removing non-word chars here
    Enum.join String.split(line, ~r/\W+/)
  end

  defp get_lineno(nil), do: nil
  defp get_lineno(token) do
    {lineno, _, _} = elem(token, 1)
    lineno
  end

  defp preprocess(ast) do
    {ast, _} = Macro.prewalk(ast, [line: 1], fn ast, prev_ctx ->
      # TODO: insert lineno in kw_list AST node e.g. [do: {...}]
      case ast do
        {:__block__, _, [nil]} ->
          {ast, prev_ctx}
        {sym, curr_ctx, args} ->
          if curr_ctx != [] and prev_ctx != [] do
            new_ctx = update_context(curr_ctx, prev_ctx)
            {{sym, new_ctx, args}, new_ctx}
          else
            {ast, prev_ctx}
          end
        _ ->
          {ast, prev_ctx}
      end
    end)
    IO.inspect ast
    ast
  end

  # TODO: rename to update_meta
  defp update_context(curr_ctx) do
    curr_lineno = curr_ctx[:line]
    # TODO: is suffix_newline necessary?
    [{:suffix_comments, get_suffix_comments(curr_lineno+1)}] ++ curr_ctx
  end
  defp update_context(curr_ctx, prev_ctx) do
    curr_lineno = curr_ctx[:line]
    prev_lineno = prev_ctx[:line]

    [{:prev, prev_lineno}] ++
    [{:prefix_comments, get_prefix_comments(curr_lineno-1, prev_lineno)}] ++
    [{:prefix_newline, get_prefix_newline(curr_lineno-1, prev_lineno)}] ++ curr_ctx
  end

  defp get_line(k), do: Agent.get(:lines, fn map -> Map.get(map, k) end)
  defp update_line(k, v), do: Agent.update(:lines, fn map -> Map.put(map, k, v) end)
  defp clear_line(k), do: Agent.update(:lines, fn map -> Map.put(map, k, nil) end)

  defp update_inline_comments(k, v) do
    Agent.update(:inline_comments, fn map ->
      if Map.has_key?(map, k) do
        val = Map.get(map, k)
        Map.put(map, k, val ++ [v])
      else
        Map.put(map, k, [v])
      end
    end)
  end
  defp get_inline_comments(k) do
    vals = Agent.get(:inline_comments, fn map -> Map.get(map, k) end)
    v = case vals do
      nil ->
        ""
      [] ->
        ""
      [v | rest] ->
        Agent.update(:inline_comments, fn map -> Map.put(map, k, rest) end)
        " " <> String.Chars.to_string(v)
    end
  end

  defp get_prefix_newline(curr, prev \\ 0) do
    if curr >= prev and get_line(curr) == "", do: "\n", else: ""
  end

  defp get_prefix_comments(curr, prev) when curr < prev, do: ""
  defp get_prefix_comments(curr, prev) do
    case get_line(curr) do
      "#" <> comment ->
        comment = get_prefix_newline(curr-1, prev) <> "#" <> comment <> "\n"
        clear_line(curr) # clear current comment to avoid duplicates
        get_prefix_comments(curr-1, prev) <> comment
      "" ->
        get_prefix_comments(curr-1, prev)
      _ ->
        ""
    end
  end

  defp get_suffix_comments(curr) do
    case get_line(curr) do
      "#" <> comment ->
        comment = "\n" <> get_prefix_newline(curr-1) <> "#" <> comment
        clear_line(curr)
        comment <> get_suffix_comments(curr+1)
      "" ->
        get_suffix_comments(curr+1)
      _ ->
        ""
    end
  end

  defp has_suffix_comments(curr) do
    case get_line(curr) do
      "#" <> _ -> true
      "" -> has_suffix_comments(curr+1)
      _ -> false
    end
  end

  defp multiline?(ast) do
    case ast do
      {_, _} -> String.length(to_string(ast)) > @line_limit/3
      {:__block__, meta, [expr]} -> meta != [] and has_suffix_comments(meta[:line]+1)
      {:__block__, _, _} -> true
      {_, meta, _} -> meta != [] and meta[:line] > meta[:prev]
      # TODO: add more 'true' cases
      _ -> true
    end
  end

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

  @doc_keywords [:doc, :moduledoc]

  # Doc comments
  def to_string({doc, _, [docstring]}, fun) when doc in @doc_keywords do
    doc = Atom.to_string(doc)

    # unwrap literal in block
    docstring = case docstring do
      {:__block__, _, [docstring]} -> docstring
      _ -> docstring
    end

    if is_atom(docstring) do
      doc <> " " <> to_string(docstring)
    else
      if sigil = sigil_call(docstring, fun) do
        doc <> " " <> sigil
      else
        # TODO: is single quote heredoc necessary?
        doc <> " \"\"\"\n" <> docstring <> "\"\"\""
      end
    end
  end

  # All other calls
  def to_string({target, _, args} = ast, fun) when is_list(args) do
    if sigil = sigil_call(ast, fun) do
      sigil
    else
      {list, last} = :elixir_utils.split_last(args)
      fun.(ast, case kw_blocks?(last) do
        true  -> call_to_string_with_args(target, list, fun) <> kw_blocks_to_string(last, fun, list)
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
    # TODO: preserve prefix newlines and comments
    fun.(list, cond do
      list == [] ->
        "[]"
      :io_lib.printable_list(list) ->
        {escaped, _} = Inspect.BitString.escape(IO.chardata_to_string(list), ?')
        IO.iodata_to_binary [?', escaped, ?']
      Inspect.List.keyword?(list) ->
        "[" <> kw_list_to_string(list, fun) <> "]"
      true ->
        "[" <> list_to_string(list, fun) <> "]"
    end)
  end

  # All other structures
  def to_string(other, fun) do
    fun.(other, inspect(other, []))
  end

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

  defp sigil_terminator(?/), do: ?/
  defp sigil_terminator(?|), do: ?|
  defp sigil_terminator(?"), do: ?"
  defp sigil_terminator(?'), do: ?'
  defp sigil_terminator(?(), do: ?)
  defp sigil_terminator(?[), do: ?]
  defp sigil_terminator(?{), do: ?}
  defp sigil_terminator(?<), do: ?>

  defp interpolate_with_terminator({:<<>>, _, parts}, terminator, fun) do
    parts = Enum.map_join(parts, "", fn
      {:::, _, [{{:., _, [Kernel, :to_string]}, _, [arg]}, {:binary, _, _}]} ->
        "\#{" <> to_string(arg, fun) <> "}"
      binary when is_binary(binary) ->
        binary = escape_terminators(binary, terminator)
    end)
    case terminator do
      [c] ->
        <<c, parts::binary, sigil_terminator(c)>>
      [c, c, c] ->
        <<c, c, c, ?\n, parts::binary, c, c, c>>
    end
  end

  defp escape_terminators(binary, terminator) do
    c = List.first terminator
    if length(terminator) == 1 do
      String.replace(binary, <<c>>, <<?\\, c>>)
    else
      binary
    end
  end

  defp module_to_string(atom, _fun) when is_atom(atom), do: inspect(atom, [])
  defp module_to_string(other, fun), do: call_to_string(other, fun)

  defp sigil_call({func, meta, [{:<<>>, _, _} = bin, args]} = ast, fun)
       when is_atom(func) and is_list(args) do
    sigil =
      case Atom.to_string(func) do
        <<"sigil_", name>> ->
          "~" <> <<name>> <>
          interpolate_with_terminator(bin, meta[:terminator], fun) <>
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

  defp call_to_string_with_args({:., _, [:erlang, :binary_to_atom]} = target, args, fun) do
    args = args_to_string(args, fun)
    |> String.split("\"")
    |> Enum.drop(-1)
    |> Enum.join()

    <<?:, ?", args::binary, ?">>
  end

  @parenless_calls [:def, :defp, :defmacro, :defmacrop, :defmodule, :if, :quote, :else, :cond, :with, :for]
  defp call_to_string_with_args(target, args, fun) do
    need_parens = not target in @parenless_calls
    target = call_to_string(target, fun)
    args = args_to_string(args, fun)
    if need_parens do
      target <> "(" <> args <> ")"
    else
      case String.trim(args) do
        "" -> target
        _ -> target <> " " <> args
      end
    end
  end

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

  defp kw_blocks_to_string(kw, fun, args) do
    {s, multiline?} = Enum.reduce(@kw_keywords, {"", false}, fn(x, acc) ->
      if Keyword.has_key?(kw, x) do
        ast = Keyword.get(kw, x)
        {s, multiline?} = acc
        multiline? = multiline? or multiline?(ast)
        s = s <> kw_block_to_string(x, ast, fun, multiline?, args)
        {s, multiline?}
      else
        acc
      end
    end)
    if multiline?, do: " " <> s <> "end", else: s
  end

  defp kw_block_to_string(key, value, fun, multiline?, args) do
    block = block_to_string(value, fun)
    args_in_front? = length(args) > 0
    if multiline? do
      block = adjust_new_lines block, "\n  "
      Atom.to_string(key) <> "\n  " <> block <> "\n"
    else
      case args_in_front? do
        true -> ", "
        false -> " "
      end <> Atom.to_string(key) <> ": " <> block
    end
  end

  defp block_to_string([{:->, _, _} | _] = block, fun) do
    Enum.map_join(block, "\n", fn({:->, _, [left, right]}) ->
      left = comma_join_or_empty_paren(left, fun, false)
      left <> "->\n  " <> adjust_new_lines block_to_string(right, fun), "\n  "
    end)
  end

  defp block_to_string({:__block__, meta, [expr]}, fun) do
    ast = {:__block__, update_context(meta), [expr]}
    fun.(ast, to_string(expr, fun))
  end

  defp block_to_string({:__block__, _, exprs}, fun) do
    Enum.map_join(exprs, "\n", &to_string(&1, fun))

  end

  defp block_to_string(other, fun), do: to_string(other, fun)

  defp map_to_string([{:|, _, [update_map, update_args]}], fun) do
    to_string(update_map, fun) <> " | " <> map_to_string(update_args, fun)
  end

  def fits?(s), do: String.length(s) <= @line_limit

  defp line_breaks?(list) when is_list(list) do
    Enum.drop(list, 1) |> Enum.any?(fn elem ->
      value = case elem do
        {_, v} -> v
        v -> v
      end
      case value do
        {_, meta, _} -> meta[:prev] < meta[:line]
        _ -> false
      end
    end)
  end
  defp line_breaks?(_), do: false

  defp prefix_comments_to_elem(elem_ast, elem_string) do
    case elem_ast do
      {_, meta, _} ->
        prefix_comments = meta[:prefix_comments]
        if prefix_comments != nil and prefix_comments != "" do
          adjust_new_lines(prefix_comments <> elem_string, "\n  ")
        else
          elem_string
        end
      _ ->
        elem_string
    end
  end

  defp map_to_string(list, fun) do
    cond do
      Inspect.List.keyword?(list) -> kw_list_to_string(list, fun)
      true -> map_list_to_string(list, fun)
    end
  end

  defp list_to_string(list, fun) do
    list_string = Enum.map_join(list, ", ", &to_string(&1, fun))
    if not fits?("  " <> list_string <> "  ") or line_breaks?(list) do
      list_to_multiline_string(list, fun)
    else
      list_string
    end
  end

  defp list_to_multiline_string(list, fun) do
    list_string = Enum.map_join(list, ",\n  ", fn value ->
      elem = adjust_new_lines(to_string(value, fn(_ast, string) -> string end), "\n  ")
      prefix_comments_to_elem(value, elem)
    end)
    "\n  " <> list_string <> ",\n"
  end

  defp kw_list_to_string(list, fun) do
    list_string = Enum.map_join(list, ", ", fn {key, value} ->
      atom_name = case Inspect.Atom.inspect(key) do
        ":" <> rest -> rest
        other       -> other
      end
      atom_name <> ": " <> to_string(value, fn(_ast, string) -> string end)
    end)
    if not fits?("  " <> list_string <> "  ") or line_breaks?(list) do
      kw_list_to_multiline_string(list, fun)
    else
      list_string
    end
  end

  defp kw_list_to_multiline_string(list, fun) do
    kw_list = Enum.map_join(list, ",\n  ", fn {key, value} ->
      atom_name = case Inspect.Atom.inspect(key) do
        ":" <> rest -> rest
        other       -> other
      end
      kw = atom_name <> ": " <> adjust_new_lines(to_string(value, fn(_ast, string) -> string end), "\n  ")
      prefix_comments_to_elem(value, kw)
    end)
    "\n  " <> kw_list <> ",\n"
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
