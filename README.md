# sortplz

_sortplz_ is a simple file sorter. It takes targeted files, and moves them to subdirectories for further review.

![Alt text](example_output.png "Example of output")

**Usage:** sortplz -f:_fromdir_ -t:_todir_ -e:_ext_

**Other flags:** _--help (-h)_, _--version (-v)_, _--silent (-s)"_

**Note:** You can specify more than one "-e" option.

## Changelog

- 2022.10.04.2 -> Initial Release
- 2022.10.04.3 -> Add colored output & partially-successful "silent" flag.
- 2022.11.04.1 -> 

## TODO

- Sort by size, instead of extension
- Sort by name, instead of extension
- It'd be nice to have the files/extensions specified without a option.
- "Silent" isn't completely silent, and only works after the other commands.
