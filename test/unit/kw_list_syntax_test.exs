defmodule ExFormat.Unit.KwListSyntaxTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "preserves keyword list syntax" do
    test "for function definitions" do
      assert_format_string("def f(), do: something\n")
      assert_format_string """
      def f() do
        something
      end
      """
    end

    test "for quote" do
      assert_format_string("quote do: something\n")
      assert_format_string """
      quote do
        something
      end
      """
    end

    test "for if else statement" do
      assert_format_string("if something, do: that_thing, else: nothing\n")
      assert_format_string """
      if something do
        that_thing
      else
        nothing
      end
      """

      assert_format_string """
      if calendar.valid_date?(year, month, day) do
        {:ok, :something}
      else
        {:error, :invalid_date}
      end
      """

      assert_format_string """
      if calendar.valid_date?(year, month, day), do: {:ok, :something}, else: {:error, :invalid_date}
      """
    end
  end

  describe "wrap calls with keyword list arguments in parentheses, if they are enclosed in list/tuple/arguments" do
    test "for calls in list" do
      assert_format_string """
      spec = [
        id: opts[:id] || __MODULE__,
        start: Macro.escape(opts[:start]) || (quote do: {__MODULE__, :start_link, [arg]}),
        restart: opts[:restart] || :permanent,
        shutdown: opts[:shutdown] || 5000,
        type: :worker,
      ]
      """

      assert_format_string """
      [last <> (if value, do: "=" <> value, else: "")]
      """
    end

    test "for calls in tuple" do
      assert_format_string """
      {:ok, div(size, bytes) + (if rem(size, bytes) == 0, do: 0, else: 1)}
      """

      assert_format_string """
      {:::, [line: line], [{name, []}, (quote do: term)]}
      """

      assert_format_string """
      :ets.insert(table, {doc_tuple, line, (if is_nil(doc), do: current_doc, else: doc)})
      """

      assert_format_string """
      {:ok, (for file <- files,
          hd(file) != ?., do: file)}
      """
    end

    test "for calls in arg list" do
      assert_format_string """
      do_setup((quote do: _), block)
      """

      assert_format_string """
      defmacro test(message, var \\\\ (quote do: _), contents) do
        something
      end
      """
    end
  end
end
