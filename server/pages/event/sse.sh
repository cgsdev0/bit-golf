# sse

topic() {
  echo "event"
}

while read -r id name; do
  SCORE="$(grep " $id" data/event_scores/* | cut -d' ' -f1 | paste -sd+ | bc)"
  event "score" "$id:${SCORE:-0}"
done < event_players
