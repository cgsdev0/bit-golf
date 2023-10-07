# headers

header Content-Type 'text/plain'
header Access-Control-Allow-Origin '*'
end_headers

PUZZLE=$(echo "${PATH_VARS[puzzle]}" | tr -d '\n' | sed 's/[^a-zA-Z0-9]//g')
if [[ ! -f "data/updoots/$PUZZLE" ]]; then
    return $(status_code 404)
fi
if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return $(status_code 405)
fi

cat "data/updoots/$PUZZLE" - <<< "${HTTP_HEADERS[cf-connecting-ip]}" \
  | sponge | sort -u > "data/updoots/$PUZZLE"
return $(status_code 200)
