#!/bin/bash

# Set variables
ACTIONSTATUS=0
EXITSTATUS=0

FILECOUNT=0
LOOPCOUNT=0

INPUT_EXTRA_PARAMS="${INPUT_EXTRA_PARAMS:-}"
INPUT_FIND_PATH="${INPUT_FIND_PATH:-.}"
INPUT_FAIL_ON_ERROR="${INPUT_FAIL_ON_ERROR:-true}"



cd "${GITHUB_WORKSPACE}"

if [ -n "${INPUT_FILE_LIST}" ]; then

  2>&1 echo "==> File List ${INPUT_FILE_LIST} specified. Linting files matching this pattern."
  IFS=', ' read -r -a FILELIST <<< "${INPUT_FILE_LIST}"
else

    if [ ! -d "${INPUT_FIND_PATH}" ]; then
          2>&1 echo "==> Can't find ${INPUT_FIND_PATH}. Please ensure INPUT_FIND_PATH is a directory relative to the root of your project."
          exit 1
    fi
    if [[ -n "${INPUT_FIND_PATTERN}" ]]; then
      2>&1 echo "==> Pattern ${INPUT_FIND_PATTERN} specified. Finding files matching this pattern."

      readarray -d '' FILELIST < <(find "${INPUT_FIND_PATH}" -name "${INPUT_FIND_PATTERN}" -print0)
    else
      2>&1 echo "INPUT_FIND_PATTERN is not set. Using '*.csv'"
      readarray -d '' FILELIST < <(find "${INPUT_FIND_PATH}" -name "*.csv" -print0)
    fi
fi


FILECOUNT=${#FILELIST[@]}


2>&1 echo "==> Found  ${FILECOUNT} files to Lint."

if [ "${FILECOUNT}" -eq 0 ]; then
  2>&1 echo "==> Nothing to do. Exiting."
  exit 0
fi

trap '' ERR

for FILE in "${FILELIST[@]}"; do
  LOOPCOUNT=$((LOOPCOUNT+1))
  2>&1 echo "==> Linting ${LOOPCOUNT} of ${FILECOUNT}. FILE: ${FILE}"
  /usr/local/sbin/csvlint ${INPUT_EXTRA_PARAMS} "${FILE}"
  EXITSTATUS=$?
  if [ ${EXITSTATUS} -ne 0 ]; then
    2>&1 echo "==> Linting errors found for ${FILE}."
    ACTIONSTATUS=${EXITSTATUS}
  fi
done

# Exit with the status of the last command and user input

if [ ${INPUT_FAIL_ON_ERROR} = "true" ] && [ ${ACTIONSTATUS} -ne 0 ]; then
  2>&1 echo "==> Linting errors found and fail_on_error is true. Exiting with error."
  exit ${ACTIONSTATUS}
elif [ ${INPUT_FAIL_ON_ERROR} = "false" ] && [ ${ACTIONSTATUS} -ne 0 ]; then
  2>&1 echo "==> Linting errors found and fail_on_error is false. Check logs for errors."
  exit 0
else
  2>&1 echo "==> No linting errors found. Exiting with success."
  exit 0
fi




