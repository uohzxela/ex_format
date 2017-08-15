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
    Lines,
  }

  @doc ~S"""
  Formats the given code string.

  It returns a tuple containing the formatted code string, as well as
  information about whether the code string was formatted successfully or not.

  ## Examples
      iex> ExFormat.format("   quote(do:  foo.bar(1,2,     3))")
      {:ok, "quote do: foo.bar(1, 2, 3)\\n"}

      iex> ExFormat.format("   quote(do:foo.bar(1,2,     3))")
      {:error, "nofile:1: keyword argument must be followed by space after: do:"}
  """
  @spec format(String.t) :: {:ok, String.t} | {:error, String.t}
  def format(code_string) do
    {:ok, format_string(code_string)}
  rescue
    e in SyntaxError ->
      {:error, Exception.message(e)}
    e in RuntimeError ->
      error_msg = """
      Error during formatting, please file a bug report at github.com/uohzxela/ex_format/issues.

      #{Exception.message(e)}
      """
      {:error, error_msg}
  after
    Lines.purge_lines_store()
  end

  @doc ~S"""
  Formats the given code string, throwing an exception in the event of failure.

  If the formatting is successful, it returns the formatted code string. Otherwise, it will throw an exception.

  ## Examples
      iex> ExFormat.format!("   quote(do:  foo.bar(1,2,     3))")
      "quote do: foo.bar(1, 2, 3)\\n"
  """
  @spec format!(String.t) :: String.t
  def format!(code_string) do
    format_string(code_string)
  after
    Lines.purge_lines_store()
  end

  defp format_string(code_string) do
    initialize_stores(code_string)
    ast = AST.initialize_ast(code_string)
    state = %State{} 
    {ast, state}
    |> AST.preprocess()
    |> Formatter.to_string_with_comments()
    |> Comments.postprocess()
  end

  defp initialize_stores(string) do
    Comments.initialize_inline_comments_store(string)
    Lines.initialize_lines_store(string)
  end
end
