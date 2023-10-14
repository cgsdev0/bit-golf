# headers

wrangle() {
  ID=$(basename "$1")
  SCORE="$(sort -n "data/event_scores/$ID" | head -n 1 | cut -d' ' -f1)"
  SCORE=${SCORE:--1}
  head -n1 "$1" | jq -c --argjson id "\"$ID\"" --argjson wr "$SCORE"  '$ARGS.named + .'
}
export -f wrangle
BS="[$(find data/event -type f | xargs  -I {} bash -c 'wrangle "$@"' _ {} | paste -sd',')]"

header Content-Type 'application/json'
header Access-Control-Allow-Origin '*'
header Content-Length "${#BS}"
end_headers

echo "$BS"
