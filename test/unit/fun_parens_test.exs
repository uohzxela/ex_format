defmodule ExFormat.Unit.FunParensTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "always use parentheses around def/defp/defmacro/defmacrop arguments" do
    test "for functions with arguments" do
      assert_format_string("def f(a), do: something\n")
      assert_format_string("defp f(a), do: something\n")
      assert_format_string("defmacro f(a), do: something\n")
      assert_format_string("defmacrop f(a), do: something\n")
      assert_format_string("defdelegate f(a), do: something\n")
    end

    test "for functions with no arguments" do
      assert_format_string("def f(), do: something\n")
      assert_format_string("defp f(), do: something\n")
      assert_format_string("defmacro f(), do: something\n")
      assert_format_string("defmacrop f(), do: something\n")
      assert_format_string("defdelegate f(), do: something\n")
    end

    test "for multiple function definitions in a block" do
      bad = """
      def f, do: something
      defp f, do: something
      defmacro f, do: something
      defmacrop f, do: something
      defdelegate f, do: something
      """
      good = """
      def f(), do: something
      defp f(), do: something
      defmacro f(), do: something
      defmacrop f(), do: something
      defdelegate f(), do: something
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
end