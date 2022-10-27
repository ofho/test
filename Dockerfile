FROM golang:alpine AS caddy	
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
	xcaddy build latest

FROM alpine:latest
COPY --from=caddy /go/caddy /usr/bin

RUN set -eux; \
    mkdir -p \
	/config/caddy \
	/data/caddy \
	/etc/caddy \
	/usr/share/caddy \
    ; \
    wget -O /etc/caddy/Caddyfile "https://github.com/caddyserver/dist/raw/8c5fc6fc265c5d8557f17a18b778c398a2c6f27b/config/Caddyfile"; \
    wget -O /usr/share/caddy/index.html "https://github.com/caddyserver/dist/raw/8c5fc6fc265c5d8557f17a18b778c398a2c6f27b/welcome/index.html"/; \
    chmod +x /usr/bin/caddy

RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
