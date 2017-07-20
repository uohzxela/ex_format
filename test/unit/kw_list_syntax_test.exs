defmodule ExFormat.Unit.KwListSyntaxTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "preserves keyword list syntax" do
    test "for function definitions" do
      assert_format_string("def f(), do: something\n")
      assert_format_string(
        """
        def f() do
          something
        end
        """
      )
    end

    test "for quote" do
      assert_format_string("quote do: something\n")
      assert_format_string(
        """
        quote do
          something
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
