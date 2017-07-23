defmodule ExFormat.Unit.LiteralTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "integer literal" do
    test "binary representation" do
      assert_format_string("0b1010\n")
      assert_format_string("0b0101", "0b101\n")
    end

    test "octal representation" do
      assert_format_string("0o17\n")
    end

    test "decimal representation" do
      assert_format_string("123\n")
      assert_format_string("01", "1\n")
    end

    test "underscores in large decimal" do
      assert_format_string("999\n")
      assert_format_string("1000", "1_000\n")
      assert_format_string("1000000", "1_000_000\n")
      assert_format_string("123123123", "123_123_123\n")
    end

    test "hexadecimal representation" do
      assert_format_string("0xEF\n")
      assert_format_string("0xef", "0xEF\n")
    end

    test "char representation" do
      assert_format_string("?è\n")
      assert_format_string("?4\n")
      assert_format_string("?\\n\n")
      assert_format_string("?\\t\n")
    end
  end

  describe "atom literal" do
    test "atom literals that need to be quoted, use double quotes around the atom name" do
      assert_format_string(":'foo-bar'", ":\"foo-bar\"\n")
      assert_format_string(":'atom number \#{index}'", ":\"atom number \#{index}\"\n")
    end
  end
end
