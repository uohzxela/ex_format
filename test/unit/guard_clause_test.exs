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

  test "indentation for multiline guard clauses should be consistent" do
    assert_format_string """
    defmacrop f(a)
              when is_atom(a) and
                a in @test1 and
                a in @test2 do
      something
    end
    """

    assert_format_string """
    defmacro f(a)
             when is_atom(a)
             |> test1()
             |> test2() do
      something
    end
    """
  end
end
