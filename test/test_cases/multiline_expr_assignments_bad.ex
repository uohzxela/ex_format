{found, not_found} = Enum.map(files, &Path.expand(&1, path))
                     |> Enum.partition(&File.exists?/1)

prefix = case base do
           :binary -> "0b"
           :octal -> "0o"
           :hex -> "0x"
         end
