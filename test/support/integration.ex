defmodule Test.Support.Integration do
  import ExUnit.Assertions

  def assert_format_file(file_name) do
    prefix = "test/test_cases/"
    bad_file = prefix <> file_name <> "_bad.ex"
    good_file = prefix <> file_name <> "_good.ex"
    assert format_file(bad_file) == File.read!(good_file)
  end

  def format_file(file_name) do
  	file_name
  	|> File.read!
  	|> ExFormat.format_string()
  end
end
