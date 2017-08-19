defmodule ExFormat do
  @moduledoc """
  ExFormat formats Elixir source code according to a standard set of rules.

  It implements most of the style rules defined in Aleksei Magusev's
  [style guide](https://github.com/lexmag/elixir-style-guide#formatting).
  """
  alias ExFormat.{
    Formatter,
    State,
    AST,
    Comments,
  }

  @doc ~S"""
  Formats the given code string.

  If the formatting is successful, it returns the formatted code string. Otherwise, it will throw an exception.

  ## Examples
      iex> ExFormat.format("   quote(do:  foo.bar(1,2,     3))")
      "quote do: foo.bar(1, 2, 3)\\n"
  """
  @spec format(String.t) :: String.t
  def format(code_string) do
    ast = AST.initialize_ast(code_string)
    state = State.initialize_state(code_string)
    {ast, state}
    |> AST.preprocess()
    |> Formatter.to_string_with_comments()
    |> Comments.postprocess()
  end
end
