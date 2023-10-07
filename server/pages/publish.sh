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

QUOTA0="${FORM_DATA[quota0]}"
QUOTA1="${FORM_DATA[quota1]}"
QUOTA2="${FORM_DATA[quota2]}"
NAME="${FORM_DATA[name]}"
PUZZLE_DATA="${FORM_DATA[puzzle]}"

if [[ -z "$NAME" ]] || [[ -z "$QUOTA0" ]] || [[ -z "$QUOTA1" ]] || [[ -z "$QUOTA2" ]] || [[ -z "$PUZZLE_DATA" ]]; then
  echo "missing quotas or puzzle"
  return $(status_code 400)
fi

FILE_ID=$(mktemp -p data/user XXXXX)
FILE_TAG=$(basename $FILE_ID)

echo "$QUOTA2 ${HTTP_HEADERS[cf-connecting-ip]} $VERIFICATION" > "data/user_scores/$FILE_TAG"
echo "${HTTP_HEADERS[cf-connecting-ip]}" > "data/updoots/$FILE_TAG"

cat > ${FILE_ID} <<-EOF
{"name":"$NAME","date":"$(date "+%m/%d/%Y")","quota0":$QUOTA0,"quota1":$QUOTA1,"quota2":$QUOTA2,"puzzle":"$PUZZLE_DATA"}
$VERIFICATION
EOF

echo "$FILE_TAG"
