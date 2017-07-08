~r/foo\//
~r/f#{:o}o\//
~R/f#{:o}o\//

~s"this is\" a string sigil\""
~s'this is\' a string sigil\''
~s(this is a string with "double" quotes, not 'single' ones)
~s(String with escape codes \x26 #{"inter" <> "polation"})
~S(String without escape codes \x26 without #{interpolation})

~w(foo bar bat)
~w(foo bar bat)a

~c(this is a char list containing 'single quotes')

regex = ~r/foo|bar/i
~r/hello/
~r|hello|
~r"hello"
~r'hello'
~r(hello)
~r[hello]
~r{hello}
~r<hello>

~S"""
Converts double-quotes to single-quotes.

## Examples

    iex> convert("\"foo\"")
    "'foo'"

"""

~S'''
'hello'
'another line'
''
'''