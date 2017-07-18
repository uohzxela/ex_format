# =CASE= Preserve comments ======
# prefix comment preserved
def hello(name) do
    # prefix comment preserved
    "hello " <> name
end
# ------
# prefix comment preserved
def hello(name) do
  # prefix comment preserved
  "hello " <> name
end
