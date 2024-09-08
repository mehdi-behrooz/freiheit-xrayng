#!/bin/bash

error=0

ip=$(
    curl --ipv4 \
        --silent \
        --fail \
        --max-time 15 \
        --retry 3 \
        --retry-all-errors \
        --retry-connrefused \
        --retry-delay 3 \
        --proxy socks5://127.0.0.1:80 \
        ip.sb
) || { ip="" && error=1; }

speed=$(
    curl --ipv4 \
        --silent \
        --fail \
        --max-time 30 \
        --retry 3 \
        --retry-all-errors \
        --retry-connrefused \
        --retry-delay 3 \
        --proxy socks5://127.0.0.1:80 \
        --output /dev/null \
        --write-out '%{speed_download}' \
        https://speed.cloudflare.com/__down?bytes=10000000
) || { speed=0 && error=1; }

speed_mb=$(bc <<<"scale=1; $speed/1024^2")

echo "ip=$ip speed=$speed_mb MB/s"
exit "$error"
