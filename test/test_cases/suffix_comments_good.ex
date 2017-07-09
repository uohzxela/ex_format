def test() do
  # comment 1
  if true do
    # comment 2
    if false do
      nil
      # comment 3
    else
      nil
      # comment 4
    end
  end
catch
  nil
  # comment 7
rescue
  nil
  # comment 8
after
  nil
  # comment 9
  # blah blah
end
