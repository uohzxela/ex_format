module = env.module
arity  = length(args)

def inspect(false), do: "false"
def inspect(true),  do: "true"
def inspect(nil),   do: "nil"