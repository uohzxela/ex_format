# comment before list is preserved
[1, 2, 3, 4, 5, 3, 5, 6, 7, 8]

[
  1,
  # comment 1
  2,
  3,
  # comment 2
  4,
  5,
  3,
  5,
  6,
  7,
  8,
]

# more comments
# multiline comments
[
  1,
  [
    2,
    3,
    4,
    5,
    6,
    3,
  ],
  5,
  6,
  7,
  [3.4, 6, 7],
]

[
  1,
  2,
  3,
  "longlonglongstring",
  "longlonglongstring",
  "longlonglongstring",
  12319910623,
  9,
  "longlonglongstring",
  "longlonglongstring",
]

[
  :this_is_a_very_long_atom,
  :here_is_the_next_atom, # inline comment1
  # comment1
  :are_we_going_to_see, # inline comment 2
  # comment2
  :any_comments?,
]

defp deps do
  [
    # Web server
    {:cowboy, "~> 1.0"},
    # Web framework
    {:phoenix, "~> 1.3.0-rc"},
    # XML parser helper
    {:sweet_xml, "~> 0.6"},
    # Statsd metrics sink client
    {:statix, "~> 1.0"},
  ]
end
