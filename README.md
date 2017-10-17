# ExFormat

[![Hex.pm](https://img.shields.io/hexpm/v/ex_format.svg)](https://hex.pm/packages/ex_format)

ExFormat formats Elixir source code according to a standard set of rules based on the [elixir-style-guide](https://github.com/lexmag/elixir-style-guide). It tries its best to accommodate the user's intent by preserving intended layout and syntax. The documentation is available [online](https://hexdocs.pm/ex_format/0.1.0/api-reference.html).

Note: ExFormat is a prototype. For a production-ready version, please have a look at the [latest code formatter](https://github.com/whatyouhide/code_formatter) that's under development by the Elixir core team. 

## Requirements

- Erlang/OTP 20
- Mix v1.5.1

## Installation

As ExFormat works best with the unreleased Elixir v1.6, it is recommended to download the prebuilt escript (which embeds Elixir v1.6 in itself) and run it as an executable.

```sh
mix escript.install https://github.com/uohzxela/ex_format/raw/master/ex_format
```

If you haven't done so already, consider adding `~/.mix/escripts` directory to your `PATH` environment variable.

## Usage

```sh
# Change directory to your Elixir project
cd to/your/elixir/project

# Formats all files that match each wildcard
ex_format lib/**/*.ex config/**/*.exs
```

## Background info

For those who are curious, the formatter is created by following these steps:

1. Parse source code into AST
2. Augment the AST nodes with metadata such comments and line breaks
3. Do a recursive descent on the AST starting from the topmost node
4. Pattern match on each node, format it according to the style guide and continue to recurse down its children nodes

Hence, conceptually, this is a very simple formatter and is a good example of how pattern matching works in practice.

There are also contributions to Elixir tokenizer and parser to augment the AST with the necessary metadata for formatting, you can check these out [here](https://github.com/elixir-lang/elixir/commits?author=uohzxela).
