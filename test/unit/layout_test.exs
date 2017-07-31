defmodule ExFormat.Unit.LayoutTest do
  import Test.Support.Unit
  use ExUnit.Case

  test "avoid aligning expression groups" do
    bad = """
    module = env.module
    arity  = length(args)

    def inspect(false), do: "false"
    def inspect(true),  do: "true"
    def inspect(nil),   do: "nil"
    """

    good = """
    module = env.module
    arity = length(args)

    def inspect(false), do: "false"
    def inspect(true), do: "true"
    def inspect(nil), do: "nil"
    """

    assert_format_string(bad, good)
  end

  describe "multiline expression assignment" do
    test "assign on next line for multiline pipelines" do
      bad = """
      {found, not_found} = Enum.map(files, &Path.expand(&1, path))
                           |> Enum.partition(&File.exists?/1)
      """
      good = """
      {found, not_found} =
        Enum.map(files, &Path.expand(&1, path))
        |> Enum.partition(&File.exists?/1)
      """
      assert_format_string(bad, good)
    end 

    test "assign on next line for case statements" do
      bad = """
      prefix = case base do
                 :binary -> "0b"
                 :octal -> "0o"
                 :hex -> "0x"
               end
      """
      good = """
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

    test "assign on next line for if else statements" do
      assert_format_string """
      foo =
        if true do
          this
        else
          that
        end
      """
    end

    test "assign on next line for cond statements" do
      assert_format_string """
      foo =
        cond bar do
          test?(bar) ->
            this
          true ->
            that
        end
      """
    end

    test "do not assign on next line for multiline maps" do
      assert_format_string """
      map = %{
        a: 1,
        b: 2,
      }
      """
    end

    test "do not assign on next line for multiline keyword lists" do
      assert_format_string """
      kw_list = [
        a: 1,
        b: 2,
      ]
      """
    end

    test "do not assign on next line for multiline lists" do
      assert_format_string """
      children = [
        MyApp.Repo,
        MyApp.Endpoint,
      ]
      """
    end

    test "do not assign on next line for multiline tuples" do
      assert_format_string """
      tuple = {
        MyApp.Repo,
        MyApp.Endpoint,
      }
      """
    end
  end

  describe "anonymous function indentation" do
    test "should indent if it has multiline expression" do
      bad = "fn k -> 1; 1+2 end"
      good = """
      fn k ->
        1
        1 + 2
      end
      """
      assert_format_string(bad, good)

      assert_format_string """
      fn ->
        1
        1 + 2
      end
      """
    end

    test "should indent if it has no multiline expression but line break is intended by user" do
      assert_format_string """
      fn k ->
        1
      end
      """
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

  describe "defstruct" do
    test "single line defstruct" do
      assert_format_string """
      defstruct structs: true, binaries: :infer, charlists: :infer
      """
    end

    test "multiline defstruct" do
      assert_format_string """
      defstruct structs: true,
                binaries: :infer,
                charlists: :infer,
                char_lists: :infer,
                limit: 50,
                printable_limit: 496,
                width: 80,
                base: :decimal,
                pretty: false,
                safe: true,
                syntax_colors: []
      """
    end
  end
end
