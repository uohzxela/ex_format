defmodule ExFormat.Unit.MapTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "map list line splitting" do
    test "do not split if map list has no line break" do
      assert_format_string("%{:a => 1, \"somekey\" => :b}\n")
    end

    test "split if map list is too long even though it has no line break" do
      bad = """
      %{:a => 1, "somelonglonglongkey" => :b, 12345679 => "somelonglonglongvalue", :some_long_atom_key => [1,2,3,5,6,7], "k1" => "aassddff"}
      """
      good = """
      %{
        :a => 1,
        "somelonglonglongkey" => :b,
        12_345_679 => "somelonglonglongvalue",
        :some_long_atom_key => [1, 2, 3, 5, 6, 7],
        "k1" => "aassddff",
      }
      """
      assert_format_string(bad, good)
    end

    test "split if map list has intended line break" do
      bad = """
      %{
      :a => 1,
      2 => :b,
      :some_atom => %{
        :key => :val,
        :key => "value",
        :key => %{
          "another day" => "another way",
          "see you in" => "july",
          "where the sun" => "shines"
        }
      }}
      """
      good = """
      %{
        :a => 1,
        2 => :b,
        :some_atom => %{
          :key => :val,
          :key => "value",
          :key => %{
            "another day" => "another way",
            "see you in" => "july",
            "where the sun" => "shines",
          },
        },
      }
      """
      assert_format_string(bad, good)
    end

    test "with complex example" do
      bad = """
      defmodule MyMod do
        def myfunc do
          assert result ==
                   %{
                     very_long_key_very_long_key1: 1,
                     very_long_key_very_long_key2: 2,
                     very_long_key_very_long_key3: 3,
                     very_long_key_very_long_key4: ["nested data structure",
                      "nested data structure",
                      "nested data structure"]}
        end
      end
      """
      good = """
      defmodule MyMod do
        def myfunc() do
          assert(result == %{
            very_long_key_very_long_key1: 1,
            very_long_key_very_long_key2: 2,
            very_long_key_very_long_key3: 3,
            very_long_key_very_long_key4: [
              "nested data structure",
              "nested data structure",
              "nested data structure",
            ],
          })
        end
      end
      """
      assert_format_string(bad, good)
    end
  end
end
