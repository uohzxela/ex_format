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

  describe "guard clause in type specs" do
    test "when guard clause is on same line as type spec" do
       assert_format_string "@spec var(var, context) :: {var, [], context} when var: atom, context: atom\n"
    end

    test "when guard clause is on different line as type spec" do
      assert_format_string """
      @spec flat_map_reduce(t, acc, fun) :: {[any], any}
            when fun: (element, acc -> {t, acc} | {:halt, acc}),
                 acc: any
      """

      assert_format_string """
      @spec send(dest, msg, [option]) :: :ok | :noconnect | :nosuspend
            when dest: pid | port | atom | {atom, node},
                 msg: any,
                 option: :noconnect | :nosuspend
      """
    end

    @tag :skip
    test "when guard clause contains Type.t, it shouldn't be parenthesized" do
      assert_format_string """
      @spec transform(Enumerable.t, acc, fun) :: Enumerable.t
            when fun: (element, acc -> {Enumerable.t, acc} | {:halt, acc}),
                 acc: any
      """
    end
  end
end
