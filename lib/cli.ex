defmodule Formatter.CLI do
  def main(args) do
  	# hello
    {opts,_,_}= OptionParser.parse(args,switches: [file: :string],aliases: [f: :file])
    Formatter.format opts[:file]
  end
end