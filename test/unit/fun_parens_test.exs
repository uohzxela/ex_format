defmodule ExFormat.Unit.FunParensTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "always use parentheses around def/defp/defmacro/defmacrop arguments" do
    test "for functions with arguments" do
      assert_format_string("def f(a), do: something\n")
      assert_format_string("defp f(a), do: something\n")
      assert_format_string("defmacro f(a), do: something\n")
      assert_format_string("defmacrop f(a), do: something\n")
    end

    test "for functions with no arguments" do
      assert_format_string("def f(), do: something\n")
      assert_format_string("defp f(), do: something\n")
      assert_format_string("defmacro f(), do: something\n")
      assert_format_string("defmacrop f(), do: something\n")
    end

    test "with multiple function definitions" do
      bad = """
      def f, do: something
      defp f, do: something
      defmacro f, do: something
      defmacrop f, do: something
      """
      good = """
      def f(), do: something
      defp f(), do: something
      defmacro f(), do: something
      defmacrop f(), do: something
      """
      assert_format_string(bad, good)

      bad = """
      def main arg1, arg2 do
        something
      end

      def main do
        something
      end
      """
      good = """
      def main(arg1, arg2) do
        something
      end

      def main() do
        something
      end
      """
      assert_format_string(bad, good)
    end
  end

  describe "always use parentheses for zero-arity function calls" do
    test "for locally defined functions" do
      good = """
      def f1(), do: something
      defp f2(), do: something
      defmacro f3(), do: something
      defmacrop f4(), do: something

      f1()
      f2()
      f3()
      f4()
      """

      bad = """
      def f1, do: something
      defp f2, do: something
      defmacro f3, do: something
      defmacrop f4, do: something

      f1
      f2
      f3
      f4
      """
      assert_format_string(bad, good)

      bad = """
      def f1(), do: something
      defp f2(), do: something
      defmacro f3(), do: something
      defmacrop f4(), do: something

      f1
      f2
      f3
      f4
      """
      assert_format_string(bad, good)
    end
  end
end
