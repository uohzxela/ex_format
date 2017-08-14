import Kernel, except: [to_string: 1]
alias ExFormat.{
  Formatter,
  State,
  AST,
  Comments,
  Lines,
}

defmodule ExFormat do
  def format(string) do
    initialize_stores(string)
    ast = AST.initialize_ast(string)
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
