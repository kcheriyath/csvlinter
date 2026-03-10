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
    - uses: actions/checkout@v4
    - name: csvlinter
      uses: kcheriyath/csvlinter@V0.7.0
      with:
        file_list: "space delimited list of files including path"
        find_pattern: "*.csv"
        find_path: "./data"
        fail_on_error: "false"
        verbose: "true"
```


file_list: "(optional) if set, linter will use this file list only and find* parameters are ignored. Use as a static list or with masesgroup/retrieve-changed-files@v3 to check only new files."

find_path: (optional, used only if file_list is not set ) if set, find command is used to search for csv files in the path, relative to project root. defaults to . (`dot`)

find_pattern: (optional, used only if file_list is not set) defaults to *.csv.

fail_on_error: "(optional) Should action fail on error. true/false. default is true".

verbose: "(optional) Set to false to reduce log output to only errors. true/false. default is true".

extra_params: (optional) extra parameters passed to the csvlint command. No default — omitting this parameter will validate against RFC 4180 strictly.

Valid parameters: 

    --lazyquotes: allow a quote to appear in an unquoted field and a non-doubled quote to appear in a quoted field. WARNING: your file may pass linting, but not parse in the way you would expect.

    --delimiter: the field delimiter, can be any single unicode character.
    default: "," (comma)
    valid options: "\t", "|", "ஃ", etc
    syntax: --delimiter='\t'

NOTE: The default settings validate that a CSV conforms to [RFC 4180](https://tools.ietf.org/html/rfc4180). By changing the settings, you can no longer strictly guarantee a CSV conforms to RFC 4180.

###

Example with an additional step for using retrieve-changed-files action

```
        - name: Spelling Checkout
          uses: actions/checkout@v4
 
        - name: Identify Changed Files
          uses: masesgroup/retrieve-changed-files@v3
          id: changed_files

        - name: csvlinter
          uses: kcheriyath/csvlinter@V0.7.0
          with:
            file_list: ${{ steps.changed_files.outputs.all }}
            extra_params: "--lazyquotes"
```

Example with verbose=false to only show errors:

```
        - name: csvlinter
          uses: kcheriyath/csvlinter@V0.7.0
          with:
            find_path: "./data"
            verbose: "false"
```

### Todo



### Done ✓

- [x] Configurable exit status with fail_on_error.
- [x] File path 
- [x] File pattern 
- [x] Ability to use a file list for only new/changed files.
- [x] Optional verbose mode to reduce log output (verbose=false shows only errors).
- [x] extra_params is now truly optional with no default (omitting it validates against RFC 4180).
