import Kernel, except: [to_string: 1]
import ExFormat.Formatter, only: [to_string_with_comments: 1]
import ExFormat.State
import ExFormat.AST
import ExFormat.Comments
import ExFormat.Lines

defmodule ExFormat do
  def format(string) do
    initialize_stores(string)
    ast = initialize_ast(string)
    state = initialize_state()
    {ast, state}
    |> preprocess()
    |> to_string_with_comments()
    |> postprocess()
  end

  defp initialize_stores(string) do
    initialize_inline_comments_store(string)
    initialize_lines_store(string)
  end
end
