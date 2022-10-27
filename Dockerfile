FROM golang:alpine AS xray
RUN apk update && apk add --no-cache git
WORKDIR /go/src/xray/core
RUN git clone --progress https://github.com/XTLS/Xray-core.git . && \
    go mod download && \
    CGO_ENABLED=0 go build -o /tmp/xray -trimpath -ldflags "-s -w -buildid=" ./main 

FROM golang:alpine AS caddy	
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    xcaddy build latest

FROM alpine:latest

ARG AUUID="90db98cc-4a43-4d87-9400-3bdcbf375cfb"
ARG CADDYIndexPage="https://github.com/AYJCSGM/mikutap/archive/master.zip"
ARG CONFIGCADDY="https://raw.githubusercontent.com/jssame/cxdxy/main/etc/Caddyfile"
ARG CONFIGXRAY="https://raw.githubusercontent.com/jssame/cxdxy/main/etc/xray.json"
ARG ParameterSSENCYPT="chacha20-ietf-poly1305"
#ARG PORT=80

COPY --from=caddy /go/caddy /usr/bin
COPY --from=xray /tmp/xray /usr/bin
COPY entrypoint.sh /usr/bin

RUN apk add --no-cache ca-certificates tor

RUN set -eux; \
    mkdir -p \
	/config/caddy \
	/data/caddy \
	/etc/caddy \
	/usr/share/caddy \
	/etc/xray \
    ; \
    chmod +x /usr/bin/caddy; \
    chmod +x /usr/bin/entrypoint.sh; \
    wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/; \
    wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile; \
    wget -qO- $CONFIGXRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/etc/xray/config.json

RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

WORKDIR /srv

CMD /usr/bin/entrypoint.sh
