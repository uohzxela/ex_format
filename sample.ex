
# handle this case:
{:::, [line: line], [{name, [line: line], []}]}

# handle this case
  defexception left: @no_value,
    right: @no_value,
    message: @no_value,
    expr: @no_value


# do not de-parenthesize nested kw list in tuple
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