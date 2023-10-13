#!/usr/bin/env bash

cd "${0%/*}"

[[ -f 'config.sh' ]] && source config.sh

if [[ "${DEV:-true}" == "true" ]] && [[ ! -z "$TAILWIND" ]]; then
   npx tailwindcss -i ./static/style.css -o ./static/tailwind.css --watch=always 2>&1 \
     | sed '/^[[:space:]]*$/d;s/^/[tailwind] /' &
   PID=$!
fi

# remove any old subscriptions; they are no longer valid
rm -rf pubsub

mkdir -p sessions
mkdir -p pubsub
mkdir -p data

# migrate data
if [[ ! -d data/default ]]; then
  mkdir -p default
  mv data/* default/.
  rm -f data/*
  mv default data/.
fi

for i in {0..14}; do
  touch data/default/$i
done

mkdir -p data/user
mkdir -p data/user_scores
mkdir -p data/event
mkdir -p data/event_scores
mkdir -p data/updoots

mkdir -p uploads

PORT=${PORT:-3000}
echo -n "Listening on port "
tcpserver -1 -o -l 0 -H -R -c 1000 0 $PORT ./core.sh

if [[ ! -z "$PID" ]]; then
  kill "$PID"
fi
