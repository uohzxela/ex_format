defmodule ExFormatTest do
  use ExUnit.Case
  import Test.Support.Integration
  doctest ExFormat

  test "the truth" do
    assert 1 + 1 == 2
  end

  # test "preservation of keyword list syntax" do
  # 	assert_format_file("kw_list_syntax")
  # end

  # test "preservation of prefix comments" do
  # 	assert_format_file("prefix_comments")
  # end

  # test "preservation of line breaks and the collapsing of contiguous line breaks into a single one" do
  # 	assert_format_file("line_breaks")
  # end

  # test "special indentation for guard clauses" do
  # 	assert_format_file("guard_clauses")
  # end

  # test "preservation of doc comments" do
  #   assert_format_file("doc_comments")
  # end

  # test "preservation of suffix comments" do
  #   assert_format_file("suffix_comments")
  # end

  # test "preservation of inline comments" do
  #   assert_format_file("inline_comments")
  # end

  # test "preservation of sigils and their terminators" do
  #   assert_format_file("sigils")
  # end

  # test "spaces around binary operators, after commas, colons and semicolons" do
  #   assert_format_file("spaces_in_code")
  # end

  # test "no spaces after unary operators and inside range literals, the only exception is the not operator" do
  #   assert_format_file("no_spaces_in_code")
  # end

  # test "spaces around default arguments \\ definition" do
  #   assert_format_file("default_arguments")
  # end

  # test "no spaces around segment options defintion in bitstrings" do
  #   assert_format_file("bitstring_segment_options")
  # end

  # TODO
  # test "use parentheses around def arguments, don't omit them even when a function has no arguments" do
  #   assert_format_file("fun_parens")
  # end

  # test "when using atom literals that need to be quoted, use double quotes around the atom name" do
  #   assert_format_file("quotes_around_atoms")
  # end

  # test "avoid aligning expression groups" do
  #   assert_format_file("expression_group_alignment")
  # end

  # test "keyword lists line splitting" do
  #   assert_format_file("kw_lists")
  # end

  test "lists line splitting" do
    assert_format_file("lists")
  end

  test "map lists line splitting" do
    assert_format_file("map_lists")
  end

  test "tuples line splitting" do
    assert_format_file("tuples")
  end

  test "pipeline indentations" do
    assert_format_file("pipeline_indentations")
  end

  test "binary op indentations" do
    assert_format_file("binary_op_indentations")
  end

  # test "anonymous function indentations" do
  #   assert_format_file("anon_funs_indentations")
  # end

  # test "multiline expression assignment" do
  #   assert_format_file("multiline_expr_assignments")
  # end

  # test "integer literals" do
  #   assert_format_file("integer_literals")
  # end
end
