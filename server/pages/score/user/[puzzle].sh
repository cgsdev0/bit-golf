# headers

header Content-Type 'text/plain'
header Access-Control-Allow-Origin '*'

PUZZLE=$(echo "${PATH_VARS[puzzle]}" | tr -d '\n' | sed 's/[^a-zA-Z0-9]//g')
if [[ ! -f "data/user_scores/$PUZZLE" ]]; then
    return $(status_code 404)
fi
VERIFICATION=$(echo "${QUERY_PARAMS[verification]}" | tr -d '\n')
if [[ "$REQUEST_METHOD" == "POST" ]]; then
  if [[ -z "$VERIFICATION" ]]; then
    echo "invalid"
    return $(status_code 400)
  fi
  NEW_SCORE=$(echo "${QUERY_PARAMS[score]}" | tr -d '\n' | sed 's/[^0-9]//g')
  echo "$NEW_SCORE ${HTTP_HEADERS[cf-connecting-ip]} $VERIFICATION" >> "data/user_scores/$PUZZLE"
fi

OUTPUT="$(sort -n "data/user_scores/$PUZZLE" | head -n 1 | cut -d' ' -f1)"

if [[ "${QUERY_PARAMS[histogram]}" == "true" ]]; then
  OUTPUT="$(cut -d' ' -f1-2 "data/user_scores/$PUZZLE" | sort -k 2,2 -k 1,1n | uniq -f1 | cut -d' ' -f1 | sort -n | uniq -c)"
fi

header Content-Length "${#OUTPUT}"
end_headers

echo "$OUTPUT"
return $(status_code 200)
