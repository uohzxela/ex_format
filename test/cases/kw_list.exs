# =CASE= Multiple function heads ======
def func1(a1,b1) do
  func3(a,b)
  1+2
end
def func1(a1,b1) do
  func3(a,b)
end
def func1(a1,b1) do
    func3(a,b)
end


# ----------------
def func1(a1, b1) do
  func3(a, b)
  1 + 2
end
def func1(a1, b1) do
  func3(a, b)
end
def func1(a1, b1) do
  func3(a, b)
end
# =CASE= Preserve keyword list syntax ======
def   func2(a2,b2),   do: func3(a,b)
def func2(a2,b2), do:       func3(a,b)
def func2(a2,   b2), do: func3(a,b)


# ------
def func2(a2, b2), do: func3(a, b)
def func2(a2, b2), do: func3(a, b)
def func2(a2, b2), do: func3(a, b)
