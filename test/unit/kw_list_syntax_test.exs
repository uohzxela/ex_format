defmodule ExFormat.Unit.KwListSyntaxTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "preserves keyword list syntax" do
    test "for function definitions" do
      assert_format_string("def func2(a2, b2), do: func3(a, b)\n")
      assert_format_string(
        """
        def func1(a1, b1) do
          func3(a, b)
        end
        """
      )
    end

    test "for quote" do
      assert_format_string("quote do: 1 + 2\n")
      assert_format_string(
        """
        quote do
          1 + 2
        end
        """
      )
    end

    test "for if else statement" do
      assert_format_string("if something, do: that_thing, else: nothing\n")
      assert_format_string(
        """
        if something do
          that_thing
        else
          nothing
        end
        """
      )
    end
  end
end
