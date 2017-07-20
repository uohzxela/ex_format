defmodule ExFormat.Unit.SigilTest do
  import Test.Support.Unit
  use ExUnit.Case

  test "preserves sigil terminators" do
    assert_format_string("~r/hello/\n")
    assert_format_string("~r|hello|\n")
    assert_format_string("~r\"hello\"\n")
    assert_format_string("~r'hello'\n")
    assert_format_string("~r(hello)\n")
    assert_format_string("~r[hello]\n")
    assert_format_string("~r{hello}\n")
    assert_format_string("~r/hello/\n")
    assert_format_string("~r<hello>\n")

    assert_format_string("~r/foo\\//\n")
    assert_format_string("~r/f#{:o}o\\//\n")
    assert_format_string("~R/f#{:o}o\\//\n")

    assert_format_string("~s(String with escape codes \\x26 #{"inter" <> "polation"})\n")
    assert_format_string("~S(String without escape codes \\x26 without \#{interpolation})\n")

    assert_format_string("~w(foo bar bat)a\n")
    assert_format_string("~c(this is a char list containing 'single quotes')\n")
  end

  test "preserves heredoc terminators" do
    assert_format_string(
      """
      ~S\"\"\"
      Converts double-quotes to single-quotes.

      ## Examples

          iex> convert("\"foo\"")
          "'foo'"

      \"\"\"
      """
    )

    assert_format_string(
      """
      ~S'''
      'hello'
      'another line'
      ''
      '''
      """
    )
  end
end
