defmodule ComparisonTest do
  use ExUnit.Case, async: true

  @case_extractor ~r/(?<name>.*) ={2,}\n(?<bad>.*)\n# -{2,}\n(?<good>.*)/s

  Enum.map(File.ls!("test/cases"), fn file ->
    File.read!("test/cases/#{file}")
    |> String.split("# =CASE=", trim: true)
    |> Enum.map(fn test_case ->
         %{"name" => name, "bad" => bad, "good" => good} = Regex.named_captures(@case_extractor, test_case)
         function_name = ExUnit.Case.register_test(__ENV__, :test, "#{String.trim(name)} (#{file})", [])
         def unquote(function_name)(_) do
           formatted = ExFormat.process_string(unquote(bad))
           expected = unquote(good)
           assert ^formatted = expected
         end
       end)
  end)
end
