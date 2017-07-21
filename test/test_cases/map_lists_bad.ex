%{:a => 1, "somekey" => :b}

%{:a => 1, "somelonglonglongkey" => :b, 12345679 => "somelonglonglongvalue", :some_long_atom_key => [1,2,3,5,6,7], "k1" => "aassddff"}

%{
:a => 1,
2 => :b,
:some_atom => %{
  :key => :val,
  :key => "value",
  :key => %{
    "another day" => "another way",
    "see you in" => "july",
    "where the sun" => "shines"
  }
}}

defmodule MyMod do
  def myfunc do
    assert result ==
             %{
               very_long_key_very_long_key1: 1,
               very_long_key_very_long_key2: 2,
               very_long_key_very_long_key3: 3,
               very_long_key_very_long_key4: ["nested data structure",
                "nested data structure",
                "nested data structure"]}
  end
end
