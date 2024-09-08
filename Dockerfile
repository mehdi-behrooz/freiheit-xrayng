# syntax=docker/dockerfile:1

FROM teddysun/xray:1.8.24 AS xray
FROM golang:1.23 AS golang
FROM alpine:3

# libcap for: setcap
# coreutils for: base64
RUN apk update && \
    apk add bash curl git libcap supervisor coreutils

RUN addgroup --system xray && \
    adduser --system --disabled-password xray --ingroup xray

COPY --from=golang /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

ARG LIBXRAY_VERSION=v3.0.2
COPY ./app/ /app/
WORKDIR /app/
RUN git clone https://github.com/XTLS/libXray.git &&\
    git -C libXray checkout tags/$LIBXRAY_VERSION &&\
    cp -r libXray/nodep/ /app/ &&\
    rm -rf libXray
RUN go mod tidy
RUN go mod download
RUN go build -o /usr/bin/subconvert

COPY --chmod=755 ./bash/ /usr/bin/
COPY --from=xray --chmod=755 /usr/bin/xray /usr/bin/xray
COPY ./xray/ /etc/xray/
RUN chown -R xray:xray /etc/xray/

# allw cron to be run as non-root
RUN setcap cap_setgid=ep /bin/busybox
ENV PERIOD_IN_MINUTES=5
RUN rm -rf /etc/crontabs/* &&\
    echo "SHELL=/bin/sh" >/etc/crontabs/xray &&\
    chown -R root:xray /etc/crontabs/ &&\
    chmod -R g+w /etc/crontabs/

COPY supervisord.conf /etc/supervisor/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

USER xray
WORKDIR /home/xray/

EXPOSE 80

HEALTHCHECK --interval=5m \
    --start-interval=30s \
    --start-period=30s \
    CMD pgrep crond || exit 1
