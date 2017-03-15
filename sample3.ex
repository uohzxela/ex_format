angle = -45
^    result = Float.parse("42.01")
2 in 1..5
not File.exists?(path)
<<102 :: unsigned-big-integer, rest :: binary>>
<<102::unsigned - big - integer, rest::binary>>

{found, not_found} = Enum.map(files, &Path.expand(&1, path))
                     |> Enum.partition(&File.exists?/1)

prefix = case base do
           :binary -> "0b"
           :octal -> "0o"
           :hex -> "0x"
         end

num = 1000000 # use underscore

:'foo-bar'
:'atom number #{index}'

[
  :foofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoo,
  :barfoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoo,
  :baz,
]

module = env.module
arity  = length(args)

def inspect(false), do: "false"
def inspect(true),  do: "true"
def inspect(nil),   do: "nil"

quote do: 1+2

def main arg1, arg2 do
  #...
end

def main do
  #...
end

Agent.get(pid, fn(state) -> state end)
Enum.reduce(numbers, fn(number, acc) ->
  acc + number
end)

"No matching message.\n"
<> "Process mailbox:\n"
<> mailbox

String.strip(input)
|> String.downcase
|> String.slice(1, 3)

with {year, ""} <- Integer.parse(year),
     {month, ""} <- Integer.parse(month),
     {day, ""} <- Integer.parse(day) do
  new(year, month, day)
else
  _ ->
    {:error, :invalid_format}
end

if byte_size(data) > 0, do: data, else: nil

cond do
  char in ?0..?9 ->
    char - ?0
  char in ?A..?Z ->
    char - ?A + 10
  :other ->
    char - ?a + 10
end


use GenServer

import Bitwise
import Kernel, except: [length: 1]

alias Mix.Utils
alias MapSet, as: Set

require Logger

sum = 1 + 2
[first | rest] = 'three'
{a1, a2} = {2, 3}
Enum.join(["one", <<"two">>, sum])

def format_error({exception, stacktrace})
    when is_list(stacktrace) and stacktrace != [] do
  # ...
end

defmacro dngettext(domain, msgid, msgid_plural, count)
         when is_binary(msgid) and is_binary(msgid_plural) do
  # ...
end

for {alias, _module} <- aliases_from_env(server),
    [name] = Module.split(alias),
    starts_with?(name, hint),
    into: [] do
  %{kind: :module, type: :alias, name: name}
end

<<0xef, 0xbb, 0xbf>>

def to_string(tree, fun \\ fn(_ast, string) -> string end)