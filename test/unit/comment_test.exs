defmodule ExFormat.Unit.CommentTest do
  import Test.Support.Unit
  use ExUnit.Case

  test "preserves prefix comments" do
    """
    # prefix comment preserved
    def hello(name) do
        # prefix comment preserved
        "hello " <> name
    end
    """ >>>
    """
    # prefix comment preserved
    def hello(name) do
      # prefix comment preserved
      "hello " <> name
    end
    """
  end

  test "preserves suffix comments" do
    """
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
    """ >>>
    """
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
  end

  test "preserves inline comments" do
    """
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
    """ >>>
    """
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
end
