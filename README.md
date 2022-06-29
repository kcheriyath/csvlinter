# CSV Linter Action

GitHub action that runs [csvlint](https://github.com/Clever/csvlint).

This action allows inputs for file paths, patterns and external file lists (check below how to use it for only changed files). There is also the ability for a configurable exit status.


## Usage

Run lint with default setting:

```
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    name: csv lint
    steps:
    - uses: actions/checkout@v3
    - name: csvlinter
      uses: kcheriyath/csvlinter@V0.6.0
      with:
        file_list: "space delmited list of files including path"
        find_pattern: "*.csv"
        find_path: "./data"
        fail_on_error: "false"
        extra_params: "--lazyquotes"
```


file_list: "(optional) if set, linter will use this file list only and find* parameters are ignored. Use as a static list or with jitterbit/get-changed-files to check only new files."

find_path: (optional) if set, find command is used to search for csv files in the path, relative to project root. defaults to . (`dot`)

find_pattern: (optional) defaults to *.csv.

fail_on_error: "(optional) Should action fail on error. true/false. default is true".

extra_params: (optional) extra parameters passed to the csvlint command.

Valid parameters: 

    --lazyquotes: allow a quote to appear in an unquoted field and a non-doubled quote to appear in a quoted field. WARNING: your file may pass linting, but not parse in the way you would expect.

    --delimiter: the field delimiter, can be any single unicode character.
    default: "," (comma)
    valid options: "\t", "|", "ஃ", etc
    syntax: --delimiter='\t'

NOTE: The default settings validate that a CSV conforms to [RFC 4180](https://tools.ietf.org/html/rfc4180). By changing the settings, you can no longer strictly guarantee a CSV conforms to RFC 4180.


### Todo



### Done ✓

- [x] Configurable exit status with fail_on_error.
- [x] File path 
- [x] File pattern 
- [x] Ability to use a file list for only new/changed files.  
