defmodule ExFormat.Unit.GuardClauseTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "guard clause" do
    test "preserves correct indentation guard clause" do
      assert_format_string """
      def f(a)
          when a > 0 do
        something
      end
      """
    end

    test "proper formatting of incorrect indentation of guard clause" do
      bad = """
      def f(a)
      when a > 0 do
        something
      end
      """

      good = """
      def f(a)
          when a > 0 do
        something
      end
      """
      assert_format_string(bad, good)
    end

    test "no formatting when guard clause is on the same line as function definition" do
      assert_format_string """
      def f(a) when a > 0 do
        something
      end
      """
    end
  end
end
