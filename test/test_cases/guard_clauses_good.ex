def func(a)
    when a > 0 do
  1 + 2
end
def func(a) when a > 0 do
  1 + 2
end

defp func(a, b)
     when a > 0 and b < 0 do
  1 + 2
end

defmacro func(a, b)
         when a > 0 and b < 0 do
  1 + 2
end