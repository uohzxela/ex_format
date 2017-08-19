# ExFormat

ExFormat formats Elixir source code according to a standard set of rules based on the [elixir-style-guide](https://github.com/lexmag/elixir-style-guide). It tries its best to accommodate the user's intent by preserving intended layout and syntax.

## Installation

As ExFormat works best with the unreleased Elixir v1.6, it is recommended to install ExFormat's escript (which embeds Elixir v1.6 in itself) and run it as an executable.

```
mix escript.install github uohzxela/ex_format
```

If you haven't done so already, consider adding `~/.mix/escripts` directory to your `PATH` environment variable.

## Usage

```
# Change directory to your Elixir project
cd to/your/elixir/project

# Formats all files that match each wildcard
ex_format lib/**/*.ex config/**/*.exs
```
