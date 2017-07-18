#=-
#=- CASE: Preserve comments
#=- BEFORE:
#=-
# prefix comment preserved
def hello(name) do
    # prefix comment preserved
    "hello " <> name
end
#=-
#=- AFTER:
#=-
# prefix comment preserved
def hello(name) do
  # prefix comment preserved
  "hello " <> name
end
#=-
