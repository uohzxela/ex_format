# elixirfmt

**An experimental Elixir code formatter.**

## Installation via Hex (not supported yet)

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `exfmt` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:exfmt, "~> 0.1.0"}]
  end
  ```

2. Ensure `exfmt` is started before your application:

  ```elixir
  def application do
    [applications: [:exfmt]]
  end
  ```

## Running locally

Run `mix escript.build` to build the executable.

Run `./exfmt [path/to/file]` to print reformatted source to standard output.

## What it can do so far

- Preserve prefix comments (suffix and inline comments are not supported yet)

  ```elixir
  # prefix comment preserved
  def hello(name) do
      # prefix comment preserved
      "hello " <> name # inline comment not preserved
      # suffix comment not preserved
  end
  ```
- Preserve line breaks and collapse contiguous line breaks into a single one
  
  Original source:
  ```elixir
  if something do
    that_thing
  else
    nothing
  end

  # comment group 1
  # comment group 1
  
  
  
  # lone comment
  
  # comment group 2
  # comment group 2

  def group(a1, b1) do
    something(a1, b1)
  end
  def group(a2, b2) do
    something(a2, b2)
  end
  
  
  def loner(a, b) do
    that_thing(a, b)
  end
  ```
  Output of Macro.to_string/2:
  
  ```elixir
  if(something) do
    that_thing
  else
    nothing
  end
  def(group(a1, b1)) do
    something(a1, b1)
  end
  def(group(a2, b2)) do
    something(a2, b2)
  end
  def(loner(a, b)) do
    that_thing(a, b)
  end
  ```
  
  Output of exfmt:
  
  ```elixir
  if something do
    that_thing
  else
    nothing
  end

  # comment group 1
  # comment group 1

  # lone comment

  # comment group 2
  # comment group 2

  def group(a1, b1) do
    something(a1, b1)
  end
  def group(a2, b2) do
    something(a2, b2)
  end

  def loner(a, b) do
    that_thing(a, b)
  end
  ```
- Preserve intended keyword list syntax (e.g. `do: something`)
  
  Original source:
  
  ```elixir
  quote   do: 1+2
  quote do
  1+2
  end


  if something, do: that_thing, else: nothing
  if something do
  that_thing
  else
          nothing
  end
  ```
  
  Output of Macro.to_string/2:
  
  ```elixir
  quote() do
    1 + 2
  end
  quote() do
    1 + 2
  end
  if(something) do
    that_thing
  else
    nothing
  end
  if(something) do
    that_thing
  else
    nothing
  end
  ```
  
  Output of exfmt:
  
  ```elixir
  quote do: 1 + 2
  quote do
    1 + 2
  end

  if something, do: that_thing, else: nothing
  if something do
    that_thing
  else
    nothing
  end
  ```
- Special indentation for guard clauses

  Original source:
  
  ```elixir
  defmacro format_error({exception, stacktrace}) 
  when is_list(stacktrace) and stacktrace != [] and a != 0 do
    1+2
  end


  defmacro format_error({exception, stacktrace}) when is_list(stacktrace) and stacktrace != [] and a != 0 do
      1+  2
  end
  ```
  
  Output of Macro.to_string/2:
  
  ```elixir
  defmacro(format_error({exception, stacktrace}) when is_list(stacktrace) and stacktrace != [] and a != 0) do
    1 + 2
  end
  defmacro(format_error({exception, stacktrace}) when is_list(stacktrace) and stacktrace != [] and a != 0) do
    1 + 2
  end
  ```
  
  Output of exfmt:
  
  ```elixir
  defmacro format_error({exception, stacktrace})
           when is_list(stacktrace) and stacktrace != [] and a != 0 do
    1 + 2
  end

  defmacro format_error({exception, stacktrace}) when is_list(stacktrace) and stacktrace != [] and a != 0 do
    1 + 2
  end
  ```
