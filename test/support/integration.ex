defmodule Test.Support.Integration do
  import ExUnit.Assertions

  def assert_format_file(file_name) do
    prefix = "test/test_cases/"
    bad_file = prefix <> file_name <> "_bad.ex"
    good_file = prefix <> file_name <> "_good.ex"
    assert ExFormat.format_file(bad_file) == File.read!(good_file)
  end
end
