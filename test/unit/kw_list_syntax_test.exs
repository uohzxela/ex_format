defmodule ExFormat.Unit.KwListSyntaxTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "preserves keyword list syntax" do
    test "for function definitions" do
      """
      def   func2(a2,b2),   do: func3(a,b)
      """ >>>
      """
      def func2(a2, b2), do: func3(a, b)
      """

      """
      def func1(a1,b1) do
          func3(a,b)
      end
      """ >>>
      """
      def func1(a1, b1) do
        func3(a, b)
      end
      """
    end

    test "for quote" do
      """
      quote   do: 1+2
      """ >>>
      """
      quote do: 1 + 2
      """

      """
      quote do
      1+2
      end
      """ >>>
      """
      quote do
        1 + 2
      end
      """
    end

    test "for if else statement" do
      """
      if something, do: that_thing, else: nothing
      """ >>>
      """
      if something, do: that_thing, else: nothing
      """

      """
      if something do
      that_thing
      else
          nothing
      end
      """ >>>
      """
      if something do
        that_thing
      else
        nothing
      end
      """
    end
  end
end
