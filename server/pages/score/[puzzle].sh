
PUZZLE=$(echo "${PATH_VARS[puzzle]}" | tr -d '\n' | sed 's/[^0-9]//g')

if [[ "$REQUEST_METHOD" == "POST" ]]; then
  touch data/$PUZZLE
  NEW_SCORE=$(echo "${QUERY_PARAMS[score]}" | tr -d '\n' | sed 's/[^0-9]//g')
  echo "$NEW_SCORE" >> data/$PUZZLE
fi

set -o pipefail
sort -n data/$PUZZLE | head -n 1 || echo NaN