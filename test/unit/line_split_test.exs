defmodule ExFormat.Unit.LineSplitTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "keyword list line splitting" do
    test "do not split if kw list has no line break" do
      assert_format_string("[k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5']\n")
    end

    test "split if kw list is too long even though it has no line break" do
      bad = "[k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5',k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5',k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5']"
      good = """
      [
        k1: 'v1',
        k2: 'v2',
        k3: 'v3',
        k4: 'v4',
        k5: 'v5',
        k1: 'v1',
        k2: 'v2',
        k3: 'v3',
        k4: 'v4',
        k5: 'v5',
        k1: 'v1',
        k2: 'v2',
        k3: 'v3',
        k4: 'v4',
        k5: 'v5',
      ]
      """
      assert_format_string(bad, good)
    end

    test "split if kw list has intended line break" do
      bad = """
      [k1: 'v1', k2: 'v2',
      k3: 'v3', k4:
      'v4', k5: 'v5']
      """
      good = """
      [
        k1: 'v1',
        k2: 'v2',
        k3: 'v3',
        k4: 'v4',
        k5: 'v5',
      ]
      """
      assert_format_string(bad, good)
    end

    test "with a complex nested example" do
      bad = """
      [
        # comment1
        # comment 2
        # comment 3
        key1: "val1",
        key2: [
          # comment 4
          k: "hello",
          k2: "something", # inline comment1
          k4: [inner: 'innerval',
          inner2: [k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',]]],
        # comment5
        key3: "val3",
      ]
      """
      good = """
      [
        # comment1
        # comment 2
        # comment 3
        key1: "val1",
        key2: [
          # comment 4
          k: "hello",
          k2: "something", # inline comment1
          k4: [
            inner: 'innerval',
            inner2: [
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
              k: 'v',
            ],
          ],
        ],
        # comment5
        key3: "val3",
      ]
      """
      assert_format_string(bad, good)
    end

    test "no trailing comma if kw list is used as arg list" do
      assert_format_string """
      for app <- apps,
          do: {app, path},
          into: %{}
      """
    end

    test "with complex example" do
      bad = """
      def project do
        [app: :mssqlex,
         version: "0.7.0",
         description: "Adapter to Microsoft SQL Server. Using DBConnection and ODBC.",
         elixir: ">= 1.4.0",
         build_embedded: Mix.env == :prod,
         start_permanent: Mix.env == :prod,
         deps: deps(),
         package: package(),
         aliases: aliases(),
         test_coverage: [tool: # Testing
          ExCoveralls],
         preferred_cli_env: ["test.local": :test, coveralls: :test, "coveralls.travis": :test],
         name: "Mssqlex",
         source_url: "https://github.com/findmypast-oss/mssqlex",
         docs: [main: "readme", extras: ["README.md"]]]
      end
      """
      good = """
      def project() do
        [
          app: :mssqlex,
          version: "0.7.0",
          description: "Adapter to Microsoft SQL Server. Using DBConnection and ODBC.",
          elixir: ">= 1.4.0",
          build_embedded: Mix.env() == :prod,
          start_permanent: Mix.env() == :prod,
          deps: deps(),
          package: package(),
          aliases: aliases(),
          test_coverage: [tool: ExCoveralls],
          preferred_cli_env: [{:"test.local", :test}, {:coveralls, :test}, {:"coveralls.travis", :test}],
          name: "Mssqlex",
          source_url: "https://github.com/findmypast-oss/mssqlex",
          docs: [main: "readme", extras: ["README.md"]],
        ]
      end
      """
      assert_format_string(bad, good)
    end
  end

  describe "list line splitting" do
    test "do not split if list has no line break" do
      assert_format_string("[1, 2, 3, 4, 5]\n")
    end

    test "split if list is too long even though it has no line break" do
      bad = "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]"
      good = """
      [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
      ]
      """
      assert_format_string(bad, good)
    end

    test "split if list has intended line break" do
      bad = """
      [1,
      [2,3,4,
      5,6,3],5,6,
      7,
      [3.4,6,7]]
      """
      good = """
      [
        1,
        [
          2,
          3,
          4,
          5,
          6,
          3,
        ],
        5,
        6,
        7,
        [3.4, 6, 7],
      ]
      """
      assert_format_string(bad, good)
    end

    test "with a complex example" do
      bad = """
      defp deps do
        [
          # Web server
         {:cowboy, "~> 1.0"},
         # Web framework
         {:phoenix, "~> 1.3.0-rc"},
         # XML parser helper
         {:sweet_xml, "~> 0.6"},
         # Statsd metrics sink client
         {:statix, "~> 1.0"}]
      end
      """
      good = """
      defp deps() do
        [
          # Web server
          {:cowboy, "~> 1.0"},
          # Web framework
          {:phoenix, "~> 1.3.0-rc"},
          # XML parser helper
          {:sweet_xml, "~> 0.6"},
          # Statsd metrics sink client
          {:statix, "~> 1.0"},
        ]
      end
      """
      assert_format_string(bad, good)
    end
  end

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
