# headers

header Content-Type 'text/plain'
header Access-Control-Allow-Origin '*'
end_headers

PUZZLE=$(echo "${PATH_VARS[puzzle]}" | tr -d '\n' | sed 's/[^0-9]//g')
VERIFICATION=$(echo "${PATH_VARS[verification]}" | tr -d '\n')

if [[ "$REQUEST_METHOD" == "POST" ]]; then
  if [[ -z "$VERIFICATION" ]]; then
    echo "invalid"
    return $(status_code 400)
  fi
  touch data/$PUZZLE
  NEW_SCORE=$(echo "${QUERY_PARAMS[score]}" | tr -d '\n' | sed 's/[^0-9]//g')
  echo "$NEW_SCORE ${HTTP_HEADERS[cf-connecting-ip]} $VERIFICATION" >> data/$PUZZLE
fi

set -o pipefail
sort -n data/$PUZZLE | head -n 1 | cut -d' ' -f1
return $(status_code 200)
