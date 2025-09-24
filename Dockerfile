ARG ALPINE_VERSION=3.22
ARG GO_VERSION=1.25

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder
WORKDIR /build

COPY ./ ./
RUN go build -ldflags "-w -s" -trimpath -o speedtest .
RUN set -eux; \
    mv web/assets/example-singleServer-gauges.html web/assets/index.html; \
    sed -i 's/LibreSpeed Example/LibreSpeed SpeedTest/g' web/assets/index.html


FROM alpine:${ALPINE_VERSION}
WORKDIR /app

ENV TZ="UTC"
RUN set -eux; \
    apk add --update --no-cache ca-certificates; \
    apk del openssl apk-tools

COPY --from=builder /build/web/assets/index.html /build/web/assets/*.js /app/assets/
COPY --from=builder /build/speedtest /build/settings.toml /app/

CMD [ "/app/speedtest" ]