# headers

header Content-Type 'text/plain'
header Access-Control-Allow-Origin '*'
end_headers

VERIFICATION=$(echo "${QUERY_PARAMS[verification]}" | tr -d '\n')

if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return $(status_code 405)
fi
if [[ -z "$VERIFICATION" ]]; then
  echo "invalid"
  return $(status_code 400)
fi

RAW_SIZE=$(echo "${FORM_DATA[raw_size]}" | tr -d '\n' | sed 's/[^0-9]//g')
QUOTA0=$(echo "${FORM_DATA[quota0]}" | tr -d '\n' | sed 's/[^0-9]//g')
QUOTA1=$(echo "${FORM_DATA[quota1]}" | tr -d '\n' | sed 's/[^0-9]//g')
QUOTA2=$(echo "${FORM_DATA[quota2]}" | tr -d '\n' | sed 's/[^0-9]//g')
NAME=$(echo "${FORM_DATA[name]}" | tr -d '\n' | sed 's/[^a-zA-Z_.0-9]//g')
PUZZLE_DATA="${FORM_DATA[puzzle]}"

if [[ -z "$NAME" ]] || [[ -z "$RAW_SIZE" ]] || [[ -z "$QUOTA0" ]] || [[ -z "$QUOTA1" ]] || [[ -z "$QUOTA2" ]] || [[ -z "$PUZZLE_DATA" ]]; then
  echo "missing quotas or puzzle"
  return $(status_code 400)
fi

if [[ "$QUOTA0" -le "$QUOTA1" ]] || [[ "$QUOTA1" -le "$QUOTA2" ]]; then
  echo "bad quotas"
  return $(status_code 400)
fi

if ! ./validate.py "$PUZZLE_DATA" "$QUOTA2" "$VERIFICATION"; then
  echo "invalid verification"
  return $(status_code 400)
fi

FILE_ID=$(mktemp -p data/event event_XXXXX)
FILE_TAG=$(basename $FILE_ID)

# echo "$QUOTA2 ${HTTP_HEADERS[cf-connecting-ip]} $VERIFICATION" > "data/event_scores/$FILE_TAG"
touch "data/event_scores/$FILE_TAG"
while read -r ID PLAYER_NAME; do
  echo "$RAW_SIZE $ID" >> "data/event_scores/$FILE_TAG"
done < event_players

cat > ${FILE_ID} <<-EOF
{"name":"$NAME","date":"$(date "+%m/%d/%Y")","quota0":$QUOTA0,"quota1":$QUOTA1,"quota2":$QUOTA2,"puzzle":"$PUZZLE_DATA","raw_size":$RAW_SIZE}
$VERIFICATION
${HTTP_HEADERS[cf-connecting-ip]}
EOF

echo "$FILE_TAG"
