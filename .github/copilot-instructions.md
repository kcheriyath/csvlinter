# Copilot Instructions for csvlinter

## Project Summary

`csvlinter` is a **GitHub Action** (Docker-based) that validates CSV and other delimiter-separated files for [RFC 4180](https://tools.ietf.org/html/rfc4180) compliance using the [`csvlint`](https://github.com/Clever/csvlint) binary (v0.3.0, Go binary). Users add it to their workflows to automatically lint CSV files on push or pull request events.

## Repository Layout

```
.
├── action.yml          # GitHub Action metadata: inputs, branding, runtime (docker)
├── Dockerfile          # Builds the Docker image; installs csvlint v0.3.0 binary
├── entrypoint.sh       # Main logic: discovers files, runs csvlint, handles exit codes
├── README.md           # Usage documentation and parameter reference
├── LICENSE             # MIT License
├── examples/
│   └── data/           # Sample CSV files used by the CI test workflow
│       ├── Backend.csv
│       ├── Cloud.csv
│       └── Web.csv
└── .github/
    ├── copilot-instructions.md   # This file
    ├── dependabot.yml            # Dependabot config (GitHub Actions ecosystem, daily)
    ├── workflows/
    │   └── csvlinter.yml         # CI: runs on PRs to main; tests the action on examples/
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

## Architecture

- **`action.yml`** declares five inputs (`file_list`, `find_path`, `find_pattern`, `extra_params`, `fail_on_error`) and specifies `runs.using: docker` with `image: Dockerfile`.
- **`Dockerfile`** is based on `ubuntu:latest`, installs `curl`, downloads and extracts the `csvlint` binary to `/usr/local/sbin/csvlint`, then sets `entrypoint.sh` as the container entrypoint.
- **`entrypoint.sh`** is the sole runtime script. It:
  1. Reads GitHub Actions input env vars (`INPUT_FILE_LIST`, `INPUT_FIND_PATH`, `INPUT_FIND_PATTERN`, `INPUT_EXTRA_PARAMS`, `INPUT_FAIL_ON_ERROR`).
  2. If `INPUT_FILE_LIST` is set, splits it on `, ` and uses that as the file list; otherwise uses `find` with `INPUT_FIND_PATH` and `INPUT_FIND_PATTERN`.
  3. Loops over each file, calls `/usr/local/sbin/csvlint ${INPUT_EXTRA_PARAMS} "${FILE}"`.
  4. Exits non-zero if `fail_on_error=true` and any lint errors occurred; exits 0 otherwise.
- There are **no unit tests** in the traditional sense. Validation is done via the CI workflow that runs the action against the example CSVs in `examples/data/`.

## Build & Run Instructions

### Building the Docker image locally

```bash
docker build -t csvlinter .
```

This downloads the `csvlint` binary from GitHub releases during the build. Requires internet access. Build takes ~30–60 seconds depending on network speed.

### Running the action locally (Docker)

```bash
# Lint all CSV files under examples/data/
docker run --rm \
  -e INPUT_FIND_PATH=examples/data \
  -e INPUT_FIND_PATTERN="*.csv" \
  -e INPUT_EXTRA_PARAMS="--lazyquotes" \
  -e INPUT_FAIL_ON_ERROR=true \
  -e GITHUB_WORKSPACE=/workspace \
  -v "$(pwd):/workspace" \
  -w /workspace \
  csvlinter
```

### Running `entrypoint.sh` directly (no Docker)

Requires `csvlint` to be installed at `/usr/local/sbin/csvlint`.

```bash
INPUT_FIND_PATH=examples/data \
INPUT_FIND_PATTERN="*.csv" \
INPUT_EXTRA_PARAMS="--lazyquotes" \
INPUT_FAIL_ON_ERROR=true \
GITHUB_WORKSPACE=$(pwd) \
bash entrypoint.sh
```

### Linting / static analysis

There is no shell linter configured in the repo. If you wish to check `entrypoint.sh` manually:

```bash
shellcheck entrypoint.sh
```

## CI Workflow (`.github/workflows/csvlinter.yml`)

- **Trigger**: Pull requests targeting `main`.
- **Steps**:
  1. `actions/checkout@v6` — checks out the repository.
  2. `masesgroup/retrieve-changed-files@v3` — identifies changed files.
  3. `kcheriyath/csvlinter@V0.6.0` — runs the action with `file_list` set to changed files, falls back to `examples/` with `*.csv` pattern.
- **Important**: The workflow uses the published action tag (`V0.6.0`), **not** the local code. To test local changes, you must build and push the Docker image, or modify the workflow to use `./` (local action) temporarily.

## Key Notes for Coding Agents

- The only runtime file is `entrypoint.sh`; most feature changes go there.
- `action.yml` must be updated when adding, removing, or renaming inputs.
- `Dockerfile` only needs changes if the base image, `csvlint` version, or system dependencies change.
- There are no package managers (no `package.json`, `requirements.txt`, `go.mod`, etc.).
- All inputs arrive as environment variables prefixed `INPUT_` (GitHub Actions convention).
- The `examples/data/` CSV files are valid RFC 4180 files and should remain passing.
- Always test changes by building the Docker image and running against `examples/data/` before opening a PR.
