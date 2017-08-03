defmodule ExFormat.Unit.KwListSyntaxTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "preserves keyword list syntax" do
    test "for function definitions" do
      assert_format_string("def f(), do: something\n")
      assert_format_string """
      def f() do
        something
      end
      """
    end

    test "for quote" do
      assert_format_string("quote do: something\n")
      assert_format_string """
      quote do
        something
      end
      """
    end

    test "for if else statement" do
      assert_format_string("if something, do: that_thing, else: nothing\n")
      assert_format_string """
      if something do
        that_thing
      else
        nothing
      end
      """

      assert_format_string """
      if calendar.valid_date?(year, month, day) do
        {:ok, :something}
      else
        {:error, :invalid_date}
      end
      """

      assert_format_string """
      if calendar.valid_date?(year, month, day), do: {:ok, :something}, else: {:error, :invalid_date}
      """
    end
  end

  describe "keyword syntax for tuples inside list" do
    test "maintain keyword sugar for tuples of size 2" do
      assert_format_string("[:foo, bar: :baz]\n")
      assert_format_string("[bar: :baz]\n")
    end

    test "enforce keyword sugar for tuples of size 2" do
      assert_format_string("[{:bar, :baz}]", "[bar: :baz]\n")
      assert_format_string("[:foo, {:bar, :baz}]", "[:foo, bar: :baz]\n")
    end

    test "do not enforce keyword sugar for tuples of size more than 2" do
      assert_format_string("[{:foo, :bar, :baz}]\n")
    end
  end
end
