defmodule ExFormat.Unit.WhiteSpaceTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "white space" do
    test "spaces around binary operators, after commas, colons and semicolons" do
      assert_format_string("sum=1+2", "sum = 1 + 2\n")
      assert_format_string("[first|     rest] ='three'", "[first | rest] = 'three'\n")
      assert_format_string("{a1, a2      } = {    2,3}", "{a1, a2} = {2, 3}\n")
      assert_format_string("Enum.join(  [\"one\",<<\"two\"   >>,sum    ]   )",
        "Enum.join([\"one\", <<\"two\">>, sum])\n")
    end

    test "no spaces after unary operators and inside range literals, the only exception is the not operator" do
      assert_format_string("angle = -   45", "angle = -45\n")
      assert_format_string("^     result = Float.parse(\"42.01\")", "^result = Float.parse(\"42.01\")\n")
      assert_format_string("2 in 1..    5", "2 in 1..5\n")
      assert_format_string("not File.exists?(path)", "not File.exists?(path)\n")
    end

    test "spaces around default arguments \\\\ definition" do
      bad =
      """
      def f(name, args\\\\[], options\\\\ []) do
        something
      end
      """

      good =
      """
      def f(name, args \\\\ [], options \\\\ []) do
        something
      end
      """
      assert_format_string(bad, good)
    end

    test "no spaces around segment options defintion in bitstrings" do
      assert_format_string("<<102 :: unsigned-big-integer, rest :: binary>>",
        "<<102::unsigned-big-integer, rest::binary>>\n")
      assert_format_string("<<102::unsigned - big - integer, rest::binary>>",
        "<<102::unsigned-big-integer, rest::binary>>\n")
    end
  end
end
