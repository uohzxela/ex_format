defmodule ComparisonTest do
  use ExUnit.Case, async: true

  @case_dir "test/cases"
  @case_split "#=- CASE:"
  @case_spacer "#=-\n"
  @case_extractor ~r/(?<name>.*)#=- BEFORE:\n(?<before_string>.*)\n#=- AFTER:\n(?<after_string>.*)/s

  Enum.map(File.ls!(@case_dir), fn file ->
    File.read!("#{@case_dir}/#{file}")
    |> String.replace(@case_spacer, "")
    |> String.split(@case_split, trim: true)
    |> Enum.map(fn test_case ->
         %{"name" => name, "before_string" => before_string, "after_string" => after_string} =
           Regex.named_captures(@case_extractor, test_case)
         function_name = ExUnit.Case.register_test(__ENV__, :test, "#{String.trim(name)} (#{file})", [])
         def unquote(function_name)(_) do
           formatted = ExFormat.process_string(unquote(before_string))
           expected = unquote(after_string)
           assert formatted == expected
         end
       end)
  end)
end
