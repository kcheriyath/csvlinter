#!/bin/bash

# Set variables
ACTIONSTATUS=0
EXITSTATUS=0

FILECOUNT=0
LOOPCOUNT=0

INPUT_EXTRA_PARAMS="${INPUT_EXTRA_PARAMS:-}"
INPUT_FIND_PATH="${INPUT_FIND_PATH:-.}"
INPUT_FAIL_ON_ERROR="${INPUT_FAIL_ON_ERROR:-true}"
INPUT_VERBOSE="${INPUT_VERBOSE:-true}"



cd "${GITHUB_WORKSPACE}"

if [ -n "${INPUT_FILE_LIST}" ]; then

  if [ "${INPUT_VERBOSE}" = "true" ]; then
    echo "==> File List ${INPUT_FILE_LIST} specified. Linting files matching this pattern." >&2
  fi
  IFS=', ' read -r -a FILELIST <<< "${INPUT_FILE_LIST}"
else

    if [ ! -d "${INPUT_FIND_PATH}" ]; then
          echo "==> Can't find ${INPUT_FIND_PATH}. Please ensure INPUT_FIND_PATH is a directory relative to the root of your project." >&2
          exit 1
    fi
    if [[ -n "${INPUT_FIND_PATTERN}" ]]; then
      if [ "${INPUT_VERBOSE}" = "true" ]; then
        echo "==> Pattern ${INPUT_FIND_PATTERN} specified. Finding files matching this pattern." >&2
      fi

      readarray -d '' FILELIST < <(find "${INPUT_FIND_PATH}" -name "${INPUT_FIND_PATTERN}" -print0)
    else
      if [ "${INPUT_VERBOSE}" = "true" ]; then
        echo "INPUT_FIND_PATTERN is not set. Using '*.csv'" >&2
      fi
      readarray -d '' FILELIST < <(find "${INPUT_FIND_PATH}" -name "*.csv" -print0)
    fi
fi


FILECOUNT=${#FILELIST[@]}


if [ "${INPUT_VERBOSE}" = "true" ]; then
  echo "==> Found  ${FILECOUNT} files to Lint." >&2
fi

if [ "${FILECOUNT}" -eq 0 ]; then
  echo "==> Nothing to do. Exiting." >&2
  exit 0
fi

trap '' ERR

for FILE in "${FILELIST[@]}"; do
  LOOPCOUNT=$((LOOPCOUNT+1))
  if [ "${INPUT_VERBOSE}" = "true" ]; then
    echo "==> Linting ${LOOPCOUNT} of ${FILECOUNT}. FILE: ${FILE}" >&2
  fi
  /usr/local/sbin/csvlint ${INPUT_EXTRA_PARAMS} "${FILE}"
  EXITSTATUS=$?
  if [ ${EXITSTATUS} -ne 0 ]; then
    echo "==> Linting errors found for ${FILE}." >&2
    ACTIONSTATUS=${EXITSTATUS}
  fi
done

# Exit with the status of the last command and user input

if [ ${INPUT_FAIL_ON_ERROR} = "true" ] && [ ${ACTIONSTATUS} -ne 0 ]; then
  echo "==> Linting errors found and fail_on_error is true. Exiting with error." >&2
  exit ${ACTIONSTATUS}
elif [ ${INPUT_FAIL_ON_ERROR} = "false" ] && [ ${ACTIONSTATUS} -ne 0 ]; then
  echo "==> Linting errors found and fail_on_error is false. Check logs for errors." >&2
  exit 0
else
  if [ "${INPUT_VERBOSE}" = "true" ]; then
    echo "==> No linting errors found. Exiting with success." >&2
  fi
  exit 0
fi




