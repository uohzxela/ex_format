defmodule ExFormat.Unit.LineSplitTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "keyword list line splitting" do
    test "do not split if kw list has no line break" do
      assert_format_string("[k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5']\n")
    end

    test "split if kw list is too long even though it has no line break" do
      bad = "[k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5',k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5',k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5']"
      good =
      """
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
      bad =
      """
      [k1: 'v1', k2: 'v2',
      k3: 'v3', k4:
      'v4', k5: 'v5']
      """
      good =
      """
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
      bad =
      """
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
      good =
      """
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
      assert_format_string(
        """
        for app <- apps,
          do: {app, path},
          into: %{}
        """
      )
    end
  end
end
