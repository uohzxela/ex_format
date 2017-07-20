defmodule Test.Support.Unit do
  import ExUnit.Assertions

  def assert_format_string(bad, good) do
    assert String.trim(ExFormat.format_string(bad)) == good
  end

  def assert_format_string(string) do
    assert String.trim(ExFormat.format_string(string)) == string
  end
end
