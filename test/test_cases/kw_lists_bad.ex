[
  # comment1
  # comment 2
  # comment 3
  key1: "val1",
  key2: [
    # comment 4
    k: "hello",
    k2: "something", # inline comment1
    k4: [inner: 'innerval',
    inner2: [k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',k: 'v',]]],
  # comment5
  key3: "val3",
]

[k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5']

[k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5',k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5',k1: 'v1', k2: 'v2', k3: 'v3', k4: 'v4', k5: 'v5']

[k1: 'v1', k2: 'v2',
k3: 'v3', k4:
'v4', k5: 'v5']

defmodule Mssqlex.Mixfile do
  use Mix.Project

  def project do
    [app: :mssqlex,
     version: "0.7.0",
     description: "Adapter to Microsoft SQL Server. Using DBConnection and ODBC.",
     elixir: ">= 1.4.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     aliases: aliases(),
     test_coverage: [tool: # Testing
      ExCoveralls],
     preferred_cli_env: ["test.local": :test, coveralls: :test, "coveralls.travis": :test],
     name: "Mssqlex",
     source_url: "https://github.com/findmypast-oss/mssqlex",
     docs: [main: "readme", extras: ["README.md"]]]
  end


  # Docs
  def application do
    [extra_applications: [:logger, :odbc]]
  end

end

for app <- apps, 
    do: {app, path},
    into: %{}