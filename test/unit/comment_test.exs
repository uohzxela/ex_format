defmodule ExFormat.Unit.CommentTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "preserves prefix comments" do

    test "for function definitions" do
      assert_format_string """
      # comment
      def f(), do: something
      """
    end

    test "for numbers" do
      assert_format_string """
      # comment
      123
      """

      assert_format_string """
      # comment
      12.3
      """

      assert_format_string """
      # comment
      0xEF
      """

      assert_format_string """
      # comment
      0b10
      """

      assert_format_string """
      # comment
      0o17
      """

      assert_format_string """
      # comment
      ?è
      """
    end

    test "for strings" do
      assert_format_string """
      # comment
      "hello"
      """
    end

    test "for lists" do
      assert_format_string """
      # comment
      [1, 2, 3]
      """
    end

    test "for tuples" do
      assert_format_string """
      # comment
      {:ok, 1}
      """

      assert_format_string """
      # comment
      {:ok, 1, 2}
      """
    end

    test "for maps" do
      assert_format_string """
      # comment
      %{:key => :value}
      """
    end

    test "for case statements" do
      assert_format_string """
      case [] do
        # comment 1
        [] ->
          :ok
        # comment 2
        [_ | _] ->
          :ok
      end
      """
    end
  end

  @tag :skip
  test "preserves suffix comments" do
    bad = """
    def test() do
      # comment 1
      if true do
        # comment 2
        if false do
          # comment 3
        else
          # comment 4
        end
        # comment 5
      end
      # comment 6
    catch
      # comment 7
    rescue
      # comment 8
    after
      # comment 9
      # blah blah
    end
    """

    good =  """
    def test() do
      # comment 1
      if true do
        # comment 2
        if false do
          nil
          # comment 3
        else
          nil
          # comment 4
        end
      end
    catch
      nil
      # comment 7
    rescue
      nil
      # comment 8
    after
      nil
      # comment 9
      # blah blah
    end
    """

    assert_format_string(bad, good)
  end

  test "preserves inline comments" do
    assert_format_string """
    def test() do # comment 0
      # asdfasdf
      1 + 2 # comment 1
      if true do # comment 2
        :random # comment 3
        :asdf # comment 4
      else # comment 5
        :hello # comment 7
      end # comment 6
    end # comment 8
    """
  end

  describe "preserves doc comments" do
    test "for @moduledoc" do
      assert_format_string """
      @moduledoc ~S\"\"\"
      # comment
      "some string"
      \"\"\"
      """

      assert_format_string """
      @moduledoc \"\"\"
      # comment
      "some string"
      \"\"\"
      """
    end

    test "for @doc" do
      assert_format_string """
      @doc ~S\"\"\"
      # comment
      "some string"
      \"\"\"
      """

      assert_format_string """
      @doc \"\"\"
      # comment
      "some string"
      \"\"\"
      """
    end

    test "with charlist" do
      assert_format_string """
      @doc ~S'''
      this is a heredoc sigil
      this is a 'charlist'
      '''
      """
    end

    test "for @typedoc" do
      assert_format_string """
      @typedoc \"\"\"
      Just a number followed by a string.
      \"\"\"
      """
    end

    test "with false" do
      assert_format_string("@doc false\n")
      assert_format_string("@moduledoc false\n")
    end
  end

  describe "preserves remaining comments after last line of code" do
    test "with config.exs sample file" do
      assert_format_string """
      # This file is responsible for configuring your application
      # and its dependencies with the aid of the Mix.Config module.
      use Mix.Config

      # This configuration is loaded before any dependency and is restricted
      # to this project. If another project depends on this project, this
      # file won't be loaded nor affect the parent project. For this reason,
      # if you want to provide default values for your application for
      # 3rd-party users, it should be done in your "mix.exs" file.

      # You can configure for your application as:
      #
      #     config :formatter, key: :value
      #
      # And access this configuration in your application as:
      #
      #     Application.get_env(:formatter, :key)
      #
      # Or configure a 3rd-party app:
      #
      #     config :logger, level: :info
      #

      # It is also possible to import configuration files, relative to this
      # directory. For example, you can emulate configuration per environment
      # by uncommenting the line below and defining dev.exs, test.exs and such.
      # Configuration from the imported file will override the ones defined
      # here (which is why it is important to import them last).
      #
      #     import_config "#{Mix.env}.exs"
      """
    end

    test "stray newlines are removed after remaining comments" do
      bad = """
      use Mix.Config

      # comment




      """
      good = """
      use Mix.Config

      # comment
      """

      assert_format_string(bad, good)
    end

    test "variable newlines are preserved between last line of code and remaining comments" do
      assert_format_string """
      use Mix.Config



      # comment
      """

      assert_format_string """
      use Mix.Config
      # comment
      """
    end
  end
end
