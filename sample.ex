# TODO: preserve do: ...
def func1(a1,b1) do
	func3(a,b)
	1+2
end
def func1(a1,b1) do
	func3(a,b)
end
def func1(a1,b1) do
	func3(a,b)
end

def func2(a2,b2), do: func3(a,b)
def func2(a2,b2), do: func3(a,b)
def func2(a2,b2), do: func3(a,b)

if something, do: asdf, else: qwer
if something do
	asdf
else
	qwer
end


# hello
# comment




def func2(a2,b2), do: func3(a,b)
def func2(a2,b2), do: func3(a,b)
def func2(a2,b2), do: func3(a,b)

# TODO: preserve multi-line indentation
a =
  "asdfasdf"
  |> "asdfasdf"
  |> "asdfasdf"

right =
  if right != [] and Keyword.keyword?(right) do
    kw_list_to_string(right, fun)
  else
    fun.(ast, op_to_string(right, fun, :when, :right))
  end

# splat when
f2 = fn
	x, y when x > 0 -> x + y
	x, y, z -> x * y + z
end

# TODO: preserve special indentation for guard clauses
defmacro format_error({exception, stacktrace}) 
	when is_list(stacktrace) and stacktrace != [] and a != 0 do
  # ...
  # hello
  1 + 2
end

# TODO: preserve anonymous fn indentation
Agent.get(pid, fn state -> state end)
Enum.reduce(numbers, fn number, acc ->
  acc + number
end)

# def asdf(arg) do
# 	1 + 2 + 3


# 	1 + 2



# 	#comment here
# 	#comment here

# 	2 + 3
# end


# comment
# def hello(arg1) do
# 	"asdfasdf" <> "b"
# end

# for partition <- 0..(partitions - 1),
#     pair <- safe_lookup(registry, partition, key),
#     into: [],
#     do: pair


# {found, not_found} =
#   Enum.map(files, &Path.expand(&1, path))
#   |> Enum.partition(&File.exists?/1)


# def inspect(false), do: 1+2+3

# defp block_to_string(other, fun), do: to_string(other, fun)