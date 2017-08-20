@spec flat_map_reduce(t, acc, fun) :: {[any], any}
      when fun: (element, acc -> {t, acc} | {:halt, acc}),
           acc: any

@spec send(dest, msg, [option]) :: :ok | :noconnect | :nosuspend
      when dest: pid | port | atom | {atom, node},
           msg: any,
           option: :noconnect | :nosuspend

@spec transform(Enumerable.t, acc, fun) :: Enumerable.t
      when fun: (element, acc -> {Enumerable.t, acc} | {:halt, acc}),
           acc: any

{:ok, div(size, bytes) + if(rem(size, bytes) == 0, do: 0, else: 1)}

spec = [
  id: opts[:id] || __MODULE__,
  start: Macro.escape(opts[:start]) || quote(do: {__MODULE__, :start_link, [arg]}),
  restart: opts[:restart] || :permanent,
  shutdown: opts[:shutdown] || 5000,
  type: :worker
]


@spec (+value) :: value when value: number
def (+value) do
  :erlang.+(value)
end

{:::, [line: line], [{name, [line: line], []}, quote(do: term)]}

:ets.insert(table, {
  doc_tuple,
  line,
  kind,
  merge_signatures(current_sign, signature, 1),
  if(is_nil(doc), do: current_doc, else: doc)
})

expanded ++ [last <> if value, do: "=" <> value, else: ""]

{:ok, for(file <- files, hd(file) != ?., do: file)}

      if @fallback_to_any do
        Kernel.defp any_impl_for(), do: __MODULE__.Any.__impl__(:target)
      else
        Kernel.defp any_impl_for(), do: nil
      end

{:cont, if target2.member?(set2, v), do: target1.put(acc, v), else: acc}

case pattern do
  {:when, meta, [left, right]} ->
    {:when, meta, [quote(do: unquote(left) = received), right]}
  left ->
    quote(do: unquote(left) = received)
end

do_setup(quote(do: _), block)

defmacro test(message, var \\ quote(do: _), contents) do
  something
end

# do not de-parenthesize kw list in tuple
{Enum.join(paths, ":"), exclude: [:test], include: [line: line]}

# escape triple quotes in docstring
  embed_template :lib, """
  defmodule <%= @mod %> do
    @moduledoc \"""
    Documentation for <%= @mod %>.
    \"""

    @doc \"""
    Hello world.

    ## Examples

        iex> <%= @mod %>.hello
        :world

    \"""
    def hello do
      :world
    end
  end
  """