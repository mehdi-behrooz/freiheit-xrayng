#!/bin/bash

is_base64() {
    base64 -d <<<"$1" &>/dev/null && printf 1
}

if [[ -z "$SUBSCRIPTION_URL" ]]; then
    echo "No env variable SUBSCRIPTION_URL defined." >&2
    exit 1
fi

if ! content="$(curl -fsS "$SUBSCRIPTION_URL")"; then
    echo "Unable to fetch $SUBSCRIPTION_URL" >&2
    exit 1
fi

if [[ $(is_base64 "$content") ]]; then
    content="$(base64 -d <<<"$content")"
fi

echo "$content"
