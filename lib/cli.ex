defmodule Formatter.CLI do
  def main(args) do
  	# hello
    {opts,_,_}= OptionParser.parse(args,switches: [file: :string],aliases: [f: :file])

    IO.inspect opts #here I just inspect the options to stdout

    ast = elem(Code.string_to_quoted(File.read!(opts[:file])), 1)
    IO.inspect ast
    IO.puts "\n"
    IO.puts Formatter.to_string ast
  end
end