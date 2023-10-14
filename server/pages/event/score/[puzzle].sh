# headers

header Content-Type 'text/plain'
header Access-Control-Allow-Origin '*'
header Access-Control-Allow-Headers 'x-postjam,x-user-id'

PUZZLE=$(echo "${PATH_VARS[puzzle]}" | tr -d '\n' | sed 's/[^a-zA-Z0-9]//g')
if [[ ! -f "data/event_scores/$PUZZLE" ]]; then
    end_headers
    return $(status_code 404)
fi
USER_ID="${HTTP_HEADERS[x-user-id]}"
if [[ -z "$USER_ID" ]]; then
    end_headers
    return $(status_code 401)
fi

if ! grep -q "$USER_ID" event_players; then
    end_headers
    return $(status_code 401)
fi

VERIFICATION=$(echo "${QUERY_PARAMS[verification]}" | tr -d '\n')
if [[ "$REQUEST_METHOD" == "POST" ]]; then
  NEW_SCORE=$(echo "${QUERY_PARAMS[score]}" | tr -d '\n' | sed 's/[^0-9]//g')
  PUZZLE_TEXT="$(head -n1 data/event/$PUZZLE | jq -r '.puzzle')"
  if ! ./validate.py "$PUZZLE_TEXT" "$NEW_SCORE" "$VERIFICATION"; then
    end_headers
    echo "invalid verification"
    return $(status_code 400)
  fi
  OLD_SCORE="$(grep " $USER_ID" "data/event_scores/$PUZZLE" | cut -d' ' -f1)"
  if [[ $NEW_SCORE -lt $OLD_SCORE ]]; then
    sed -i "s/$OLD_SCORE $USER_ID/$NEW_SCORE $USER_ID/" "data/event_scores/$PUZZLE"
    TOTAL_SCORE="$(grep " $USER_ID" data/event_scores/* |cut -d':' -f2 | cut -d' ' -f1 | paste -sd+ | bc)"
    event update "$USER_ID:$TOTAL_SCORE" | publish event
  fi
fi

OUTPUT="$(sort -n "data/event_scores/$PUZZLE" | head -n 1 | cut -d' ' -f1)"

if [[ "${QUERY_PARAMS[histogram]}" == "true" ]]; then
  OUTPUT="$(cut -d' ' -f1-2 "data/event_scores/$PUZZLE" | sort -k 2,2 -k 1,1n | uniq -f1 | cut -d' ' -f1 | sort -n | uniq -c)"
fi

header Content-Length "${#OUTPUT}"
end_headers

echo "$OUTPUT"
return $(status_code 200)
