defmodule Test.Support.Unit do
  import ExUnit.Assertions

  def assert_format_string(bad, good) do
    assert ExFormat.format(bad) == good
    assert ExFormat.format(good) == good
  end

  def assert_format_string(string) do
    assert_format_string(string, string)
  end
end
