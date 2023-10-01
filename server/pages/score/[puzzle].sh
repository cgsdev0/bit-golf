
PUZZLE=$(echo "${PATH_VARS[puzzle]}" | tr -d '\n' | sed 's/[^0-9]//g')

if [[ "$REQUEST_METHOD" == "POST" ]]; then
  touch data/$PUZZLE
  echo "${QUERY_PARAMS[score]}" | tr -d '\n' | sed 's/[^0-9]//g' >> data/$PUZZLE
fi

set -o pipefail
sort -n data/$PUZZLE | head -n 1 || echo NaN
