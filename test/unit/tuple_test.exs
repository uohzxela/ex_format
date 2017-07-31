defmodule ExFormat.Unit.TupleTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "tuple line splitting" do
    test "do not split if tuple has no line break" do
      assert_format_string("{:ok, :test, :test, :test}\n")
    end

    test "split if tuple is too long even though it has no line break" do
      bad = """
      {:ok, :test, :test, :test, :ok, :test, :test, :test, :ok, :test, :test, :test, :ok, :test, :test, :test, :ok, :test, :test, :test}
      """
      good = """
      {
        :ok,
        :test,
        :test,
        :test,
        :ok,
        :test,
        :test,
        :test,
        :ok,
        :test,
        :test,
        :test,
        :ok,
        :test,
        :test,
        :test,
        :ok,
        :test,
        :test,
        :test,
      }
      """
      assert_format_string(bad, good)
    end

    test "split if tuple has intended line break" do
      bad = """
      {:ok,
      :test}
      """
      good = """
      {
        :ok,
        :test,
      }
      """
      assert_format_string(bad, good)
    end

    test "with complex example" do
      bad = """
      {:ok,
      # comment 1
      :lets_have_some, {:inner, :tuples!},
      # comment 2
      # comment 3
      :are_you, {:ready_to_have, "more and more", "tuples", {"nested",
      # comment 4
      "close", "together", {:is_this,
       123123, "possible?"}}},
      "last element standing"} # inline comment 2
      """
      good = """
      {
        :ok,
        # comment 1
        :lets_have_some,
        {:inner, :tuples!},
        # comment 2
        # comment 3
        :are_you,
        {
          :ready_to_have,
          "more and more",
          "tuples",
          {
            "nested",
            # comment 4
            "close",
            "together",
            {
              :is_this,
              123_123,
              "possible?",
            },
          },
        },
        "last element standing", # inline comment 2
      }
      """
      assert_format_string(bad, good)
    end
  end
end
