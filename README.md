# Freiheit XrayNG

## Intro

A small client for testing Freiheit Xray servers.

## How to use

Print number of subcscriptions:

```bash
docker run --rm -e SUBSCRIPTION_URL="https://my.subscription/url" \
    ghcr.io/mehdi-behrooz/freiheit-xrayng:latest count
```

Print subscription labels:

```bash
docker run --rm -e SUBSCRIPTION_URL="https://my.subscription/url" \
    ghcr.io/mehdi-behrooz/freiheit-xrayng:latest list
```

Test subscription connectivity:

```bash
docker run --rm -e SUBSCRIPTION_URL="https://my.subscription/url" \
    ghcr.io/mehdi-behrooz/freiheit-xrayng:latest check 2

docker run --rm -e SUBSCRIPTION_URL="https://my.subscription/url" \
    ghcr.io/mehdi-behrooz/freiheit-xrayng:latest check 2,3
```

Connect to subsciption:

```bash
docker run --rm -e SUBSCRIPTION_URL="https://my.subscription/url" \
    -p 1080:80 ghcr.io/mehdi-behrooz/freiheit-xrayng:latest connect 3

curl -x socks5://127.0.0.1:1080 ip.sb
```

Monitor subscription:

```bash
docker run --rm -e SUBSCRIPTION_URL="https://my.subscription/url" \
    -e INDEX_TO_CHECK=2,3 -e ASSERT_COUNT=8 -e PERIOD_IN_MINUTES=1 \
    ghcr.io/mehdi-behrooz/freiheit-xrayng:latest
``




```
