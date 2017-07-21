defmodule ExFormat.Unit.LayoutTest do
  import Test.Support.Unit
  use ExUnit.Case

  test "avoid aligning expression groups" do
    bad =
    """
    module = env.module
    arity  = length(args)

    def inspect(false), do: "false"
    def inspect(true),  do: "true"
    def inspect(nil),   do: "nil"
    """

    good =
    """
    module = env.module()
    arity = length(args)

    def inspect(false), do: "false"
    def inspect(true), do: "true"
    def inspect(nil), do: "nil"
    """

    assert_format_string(bad, good)
  end

  test "multiline expression assignment" do
    bad =
    """
    {found, not_found} = Enum.map(files, &Path.expand(&1, path))
                         |> Enum.partition(&File.exists?/1)
    """

    good =
    """
    {found, not_found} =
      Enum.map(files, &Path.expand(&1, path))
      |> Enum.partition(&File.exists?() / 1)
    """

    assert_format_string(bad, good)

    bad =
    """
    prefix = case base do
               :binary -> "0b"
               :octal -> "0o"
               :hex -> "0x"
             end
    """

    good =
    """
    prefix =
      case base do
        :binary ->
          "0b"
        :octal ->
          "0o"
        :hex ->
          "0x"
      end
    """

    assert_format_string(bad, good)
  end

  describe "anonymous function indentation" do
    test "should indent if it has multiline expression" do
      bad = "fn k -> 1; 1+2 end"
      good =
      """
      fn k ->
        1
        1 + 2
      end
      """
      assert_format_string(bad, good)

      assert_format_string(
        """
        fn ->
          1
          1 + 2
        end
        """
      )
    end

    test "should indent if it has no multiline expression but line break is intended by user" do
      assert_format_string(
        """
        fn k ->
          1
        end
        """
      )
      # this is a failing test because we have no way to detect line break if there's no fn args
      # assert_format_string(
      #   """
      #   fn ->
      #     1
      #   end
      #   """
      # )
    end

    test "should not indent if there is no multiline expression and no line break" do
      assert_format_string("fn k -> 1 end\n")
      assert_format_string("fn -> 1 end\n")
    end
  end
end
