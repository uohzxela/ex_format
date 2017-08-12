defmodule ExFormat.Unit.FunArgsTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "split args if they are too long for function calls" do
    test "with remote calls" do
      bad = "Enum.map_join(some_very_long_function_name1(args), some_very_long_function_name2(delimiter), &to_string(&1, fun, state))"
      good = """
      Enum.map_join(some_very_long_function_name1(args),
                    some_very_long_function_name2(delimiter),
                    &to_string(&1, fun, state))
      """
      assert_format_string(bad, good)
    end

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
end
