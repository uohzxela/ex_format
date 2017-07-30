defmodule ExFormat.Unit.CaptureTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "capture syntax should not parenthesize" do
    test "direct functions" do
      assert_format_string("&foo(&1)\n")
      assert_format_string("&foo/1\n")
    end

    test "remote functions" do
      assert_format_string("&List.flatten(&1, &2)\n")
      assert_format_string("&List.flatten/2\n")

      assert_format_string("&:erlang.is_function(&1)\n")
      assert_format_string("&:erlang.is_function/1\n")
    end

    test "anonymous lists/tuples" do
      assert_format_string("&[&1, &2]\n")
      assert_format_string("&{&1, &2}\n")
    end
  end

  describe "capture syntax should parenthesize" do
    test "binary operations" do
      assert_format_string("&(&1 + 1)\n")
      assert_format_string("&(&1 / 1)\n")
      assert_format_string("&(&&/2)\n")
      assert_format_string("& &&/2", "&(&&/2)\n")
      assert_format_string("&(&&&/2)\n")
      assert_format_string("& &&&/2", "&(&&&/2)\n")
    end
  end
end
