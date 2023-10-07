# headers

BS="[$(for PUZZLE in {0..14}; do
  set -o pipefail
  sort -n data/default/$PUZZLE | head -n 1 | cut -d' ' -f1 || echo -1
done | paste -sd',')]"

header Content-Type 'application/json'
header Access-Control-Allow-Origin '*'
header Content-Length "${#BS}"
end_headers

echo "$BS"
