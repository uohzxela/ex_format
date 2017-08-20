defmodule ExFormat.Unit.GuardClauseTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "guard clause" do
    test "preserves correct indentation guard clause" do
      assert_format_string """
      def f(a)
          when a > 0 do
        something
      end
      """
    end

    test "proper formatting of incorrect indentation of guard clause" do
      bad = """
      def f(a)
      when a > 0 do
        something
      end
      """

      good = """
      def f(a)
          when a > 0 do
        something
      end
      """
      assert_format_string(bad, good)
    end

    test "no formatting when guard clause is on the same line as function definition" do
      assert_format_string """
      def f(a) when a > 0 do
        something
      end
      """
    end
  end

  describe "indentation for multiline guard clauses" do
    test "with binary ops" do
      assert_format_string """
        defmacrop f(a)
                  when is_atom(a) and
                       a in @test1 and
                       a in @test2 do
          something
        end
        """
    end

    test "with pipelines" do
      assert_format_string """
      defmacro f(a)
               when is_atom(a)
                    |> test1()
                    |> test2() do
        something
      end
      """
    end

    test "with multiple guards" do
      assert_format_string """
      defp valid_identifier_char?(char)
           when char in ?a..?z
           when char in ?A..?Z
           when char in ?0..?9
           when char == ?_ do
        true
      end
      """
    end
  end

  describe "indentation for guard clause on same line as function definition" do
    test "with binary ops" do
      assert_format_string """
        defmacrop f(a) when is_atom(a) and
                            a in @test1 and
                            a in @test2 do
          something
        end
        """
    end

    test "with pipelines" do
      assert_format_string """
      defmacro f(a) when is_atom(a)
                         |> test1()
                         |> test2() do
        something
      end
      """
    end

    test "with multiple guards" do
      bad = """
      defp valid_identifier_char?(char) when char in ?a..?z
                                        when char in ?A..?Z
                                        when char in ?0..?9
                                        when char == ?_ do
        true
      end
      """

      good = """
      defp valid_identifier_char?(char)
           when char in ?a..?z
           when char in ?A..?Z
           when char in ?0..?9
           when char == ?_ do
        true
      end
      """

      assert_format_string(bad, good)
    end

    test "with case statements" do
      assert_format_string """
      case o do
        oooooo when o in [
                      :<-,
                      :<-,
                    ] ->
          true
      end
      """
    end
  end

  test "guard clause in type specs" do
    assert_format_string "@spec var(var, context) :: {var, [], context} when var: atom, context: atom\n"
  end
end
