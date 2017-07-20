defmodule ExFormat.Unit.IntegerTest do
  import Test.Support.Unit
  use ExUnit.Case, async: true

  test "integer" do
    assert_format_string("123")
  end
end
