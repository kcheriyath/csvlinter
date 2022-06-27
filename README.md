# CSV Linter Action

GitHub action that runs `csvlint`.

The project is heavily based on salt-lint-action, which was created by Roald Nefs and the original csv-lint action by blackstar257 at [docker-csvlint](https://github.com/blackstar257/docker-csvlint).

Main enhancement to `docker-csvlint` is to be able to provide a search path and file pattern.


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
    - name: Run csv-lint
      uses: kcheriyath/csvlinter@main
      with:
        find_pattern: "*.csv"
        find_path: "./data"
        fail_on_error: "false"
        extra_params: "--lazyquotes"
```


find_path: (optional) when defined, find command is used to search for csv files in the path, relative to project root. defaults to . (`dot`)

find_pattern: (optional) defaults to *.csv.

fail_on_error: "(optional) Should action fail on error. true/false. default is true".

extra_params: (optional) extra parameters passed to the csv-lint command.

Valid parameters: 

    lazyquotes: allow a quote to appear in an unquoted field and a non-doubled quote to appear in a quoted field. WARNING: your file may pass linting, but not parse in the way you would expect.

    delimiter: the field delimiter, can be any single unicode character.
    default: "," (comma)
    valid options: "\t", "|", "ஃ", etc

NOTE: The default settings validate that a CSV conforms to [RFC 4180](https://tools.ietf.org/html/rfc4180). By changing the settings, you can no longer strictly guarantee a CSV conforms to RFC 4180.
