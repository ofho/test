#!/bin/sh

# args
AUUID="36c9cb20-c239-4a70-8273-5da229049f62"
CADDYIndexPage="https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html"
CONFIGCADDY="https://raw.githubusercontent.com/jssame/cxdxy/main/etc/Caddyfile"
CONFIGXRAY="https://raw.githubusercontent.com/jssame/cxdxy/main/etc/xray.json"
ParameterSSENCYPT="chacha20-ietf-poly1305"
#PORT=80

# configs
mkdir -p /etc/caddy/ /usr/share/caddy /etc/xray/ && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGXRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/etc/xray/config.json

# start
tor &
xray -config /etc/xray/config.json &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
