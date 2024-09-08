#!/bin/bash

DEFAULT_CHECK_COMMAND="/usr/bin/measure.sh"

url_decode() {
    read -r t <&0
    t="${t//+/ }"
    printf '%b\n' "${t//%/\\x}"
}

test_sub() {
    rm -f /etc/xray/outbound.json
    /usr/bin/subconvert "$1" >/etc/xray/outbound.json
    killall /usr/bin/xray &>/dev/null
    /usr/bin/xray run -confdir /etc/xray/ >/dev/null 2>&1 &
    output=$($CHECK_COMMAND)
    local error="$?"
    echo "Testing ${1#*\#}: $output" | url_decode
    return $error
}

if [[ -z "$CHECK_COMMAND" ]]; then
    CHECK_COMMAND=$DEFAULT_CHECK_COMMAND
fi

fetch="$(/usr/bin/fetch.sh)" || exit 1
readarray -t subs <<<"$fetch"
count="${#subs[@]}"

error=0

if [[ -n "$ASSERT_COUNT" ]]; then
    if [[ "$count" -eq "$ASSERT_COUNT" ]]; then
        echo "$count subs exists. OK."
    else
        echo "ERROR: $count subs existed instead of $ASSERT_COUNT" >&2
        error=1
    fi
fi
if [[ "$INDEX_TO_CHECK" == "*" ]]; then
    INDEX_TO_CHECK="$(seq -s, 1 "$count")"
fi
IFS=', ' read -r -a indexes <<<"$INDEX_TO_CHECK"
for index in "${indexes[@]}"; do
    test_sub "${subs[$((index - 1))]}" || error=1
done
exit "$error"
