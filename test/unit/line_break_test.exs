defmodule ExFormat.Unit.LineBreakTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "line breaks" do
    test "for comments" do
      assert_format_string(
        """
        # solo

        # group
        # group

        # solo
        def f(), do: something
        """
      )
    end

    test "for function definitions" do
      assert_format_string(
        """
        def f1(), do: something
        def f1(), do: something
        def f1(), do: something

        def f2(), do: something
        def f2(), do: something

        def f3(), do: something
        def f3(), do: something
        """
      )
    end
  end
end
