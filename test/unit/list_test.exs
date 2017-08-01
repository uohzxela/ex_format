defmodule ExFormat.Unit.ListTest do
  import Test.Support.Unit
  use ExUnit.Case

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

    test "with complex examples" do
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

      assert_format_string """
      defstruct [
        # The TCP socket that holds the connection to Redis
        socket: nil,
        # Options passed when the connection is started
        opts: nil,
        # The receiver process
        receiver: nil,
        # The shared state store process
        shared_state: nil,
        # The current backoff (used to compute the next backoff when reconnecting
        # with exponential backoff)
        backoff_current: nil,
      ]
      """
    end
  end
end
