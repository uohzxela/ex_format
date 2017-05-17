# prefix comment preserved
def hello(name) do
    # prefix comment preserved
    "hello " <> name # inline comment not preserved
    # suffix comment not preserved
end