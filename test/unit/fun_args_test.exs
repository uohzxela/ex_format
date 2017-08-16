defmodule ExFormat.Unit.FunArgsTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "split function call args if they are too long" do
    @tag :skip
    test "with remote calls" do
      bad = "Enum.map_join(some_very_long_function_name1(args), some_very_long_function_name2(delimiter), &to_string(&1, fun, state))"
      good = """
      Enum.map_join(some_very_long_function_name1(args),
                    some_very_long_function_name2(delimiter),
                    &to_string(&1, fun, state))
      """
      assert_format_string(bad, good)
    end

    @tag :skip
    test "with local calls" do
      bad = "local_call(some_very_long_function_name1(args), some_very_long_function_name2(delimiter), &to_string(&1, fun, state))"
      good = """
      local_call(some_very_long_function_name1(args),
                 some_very_long_function_name2(delimiter),
                 &to_string(&1, fun, state))
      """
      assert_format_string(bad, good)
    end
  end

  describe "split function call args if they have intended line break" do
    @tag :skip
    test "with remote calls" do
      bad = """
      Enum.map_join(args,
        delimiter, &to_string(&1, fun, state))
      """
      good = """
      Enum.map_join(args,
                    delimiter,
                    &to_string(&1, fun, state))
      """
      assert_format_string(bad, good)
    end

    @tag :skip
    test "with local calls" do
      bad = """
      local_call(args, delimiter,
        &to_string(&1, fun, state))
      """
      good = """
      local_call(args,
                 delimiter,
                 &to_string(&1, fun, state))
      """
      assert_format_string(bad, good)
    end
  end
end
