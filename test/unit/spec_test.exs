defmodule ExFormat.Unit.SpecTest do
  import Test.Support.Unit
  use ExUnit.Case

  @tag :skip
  test "split specs to multiple lines if they are very long" do
    assert_format_string("@callback handle_call(request :: term, state :: term) :: {:ok, reply, new_state} | {:ok, reply, new_state, :hibernate} | {:remove_handler, reply}\n")
    assert_format_string("@type mode :: :append | :binary | :charlist | :compressed | :delayed_write | :exclusive | :raw | :read | :read_ahead | :sync | :utf8 | :write | {:encoding, :latin1 | :unicode | :utf8 | :utf16 | :utf32 | {:utf16, :big | :little} | {:utf32, :big | :little}} | {:read_ahead, pos_integer} | {:delayed_write, non_neg_integer, non_neg_integer}\n")
  end

  @tag :skip
  test "do not parenthesize left side of :: when they are nested" do
  	assert_format_string("@callback handle_expr(state, marker :: String.t, expr :: Macro.t) :: state\n")
  end
end
