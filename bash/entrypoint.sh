#!/bin/bash

url_decode() {
    read -r t <&0
    t="${t//+/ }"
    printf '%b\n' "${t//%/\\x}"
}

case "$1" in

count)
    fetch="$(/usr/bin/fetch.sh)" || exit 1
    readarray -t subs <<<"$fetch"
    count="${#subs[@]}"
    echo "$count"
    exit 0
    ;;

list)
    fetch="$(/usr/bin/fetch.sh)" || exit 1
    readarray -t subs <<<"$fetch"
    for sub in "${subs[@]}"; do
        echo "${sub#*\#}" | url_decode
    done
    exit 0
    ;;

connect)
    fetch="$(/usr/bin/fetch.sh)" || exit 1
    readarray -t subs <<<"$fetch"
    count="${#subs[@]}"
    if [[ -z "$2" ]]; then
        echo "expected two arguments: connect \$n" >&2
        exit 1
    fi
    if [[ ! "$2" =~ ^[0-9]+$ ]]; then
        echo "invalid index: '$2'. index should be a number" >&2
        exit 1
    fi
    if [[ "$2" -lt "1" || "$2" -gt "$count" ]]; then
        echo "invalid index: index should be between 1 and $count" >&2
        exit 1
    fi
    sub="${subs[$(($2 - 1))]}"
    echo "Connecting to ${sub#*\#}..." | url_decode
    /usr/bin/subconvert "$sub" >/etc/xray/outbound.json
    exec /usr/bin/xray run -confdir /etc/xray/
    ;;

check)
    fetch="$(/usr/bin/fetch.sh)" || exit 1
    readarray -t subs <<<"$fetch"
    INDEX_TO_CHECK="${*:2}" /usr/bin/check.sh
    exit "$?"
    ;;

*)
    echo "*/$PERIOD_IN_MINUTES * * * * /usr/bin/check.sh" \
        >>/etc/crontabs/xray
    exec "$@"
    ;;

esac
