defmodule ExFormat.Unit.TupleTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "tuple line splitting" do
    test "do not split if tuple has no line break" do
      assert_format_string("{:ok, :test, :test, :test}\n")
    end

    test "do not split if tuple is too long" do
      assert_format_string """
      {:ok, :test, :test, :test, :ok, :test, :test, :test, :ok, :test, :test, :test, :ok, :test, :test, :test, :ok, :test, :test, :test}
      """
    end

    test "do not split if tuple has intended line break" do
      bad = """
      {:ok,
      :test}
      """
      good = """
      {:ok, :test}
      """
      assert_format_string(bad, good)
    end
  end

  describe "tuple calls" do
    test "with arguments on same line" do
      assert_format_string("alias Foo.{Bar, Baz}\n")
    end

    test "with arguments on multiple lines" do
      assert_format_string """
      alias Foo.{
        Bar,
        Baz,
      }
      """
    end
  end

  test "empty tuple" do
    assert_format_string("{}\n")
  end
end
