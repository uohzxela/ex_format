defmodule ExFormatTest do
  use ExUnit.Case
  doctest ExFormat

  def assert_formatted_content(file_name) do
  	prefix = "test/test_cases/"
  	bad_file = prefix <> file_name <> "_bad.ex"
  	good_file = prefix <> file_name <> "_good.ex"
	assert ExFormat.process(bad_file) == File.read!(good_file)
  end

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "preservation of keyword list syntax" do
  	assert_formatted_content("kw_list")
  end

  test "preservation of prefix comments" do
  	assert_formatted_content("prefix_comments")
  end

  test "preservation of line breaks and the collapsing of contiguous line breaks into a single one" do
  	assert_formatted_content("line_breaks")
  end

  test "special indentation for guard clauses" do
  	assert_formatted_content("guard_clauses")
  end

  test "preservation of doc comments" do
    assert_formatted_content("doc_comments")
  end

  test "preservation of suffix comments" do
    assert_formatted_content("suffix_comments")
  end
end
