defmodule ExFormat.Unit.IntegerTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "integer literal" do
    test "binary representation" do
      assert_format_string("0b1010\n")
      "0b0101" >>> "0b101\n"
    end

    test "octal representation" do
      assert_format_string("0o17\n")
    end

    test "decimal representation" do
      assert_format_string("123\n")
      "01" >>> "1\n"
    end

    test "hexadecimal representation" do
      assert_format_string("0xEF\n")
      "0xef" >>> "0xEF\n"
    end

    test "char representation" do
      assert_format_string("?è\n")
      assert_format_string("?4\n")
    end
  end
end
