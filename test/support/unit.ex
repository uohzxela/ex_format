defmodule Test.Support.Unit do
  import ExUnit.Assertions

  def assert_format_string(bad, good) do
    assert ExFormat.format_string(bad) == good
  end

  def assert_format_string(string) do
    assert_format_string(string, string)
  end

  def bad >>> good do
    assert_format_string(bad, good)
  end
end
