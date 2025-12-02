#!/bin/sh
set -e

apk add --no-cache curl jq wget

if [ -z "$TARGET_URL" ] || [ -z "$YEAR" ]; then
  exit 1
fi

json=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$TARGET_URL&to=${YEAR}1231&output=json&fl=original,timestamp&filter=statuscode:200&limit=1&collapse=timestamp:8&sort=reverse")
timestamp=$(echo "$json" | jq -r '.[1][1]')
file_url=$(echo "$TARGET_URL" | sed 's/:80//')
wayback_url="https://web.archive.org/web/${timestamp}id_/$file_url/"

if [ -z "$(ls -A /usr/share/nginx/html)" ]; then
  wget --mirror --convert-links --page-requisites --no-parent robots=off -P /usr/share/nginx/html "$wayback_url" || true
  mv "/usr/share/nginx/html/web.archive.org/web/${timestamp}id_/$file_url/"/* "/usr/share/nginx/html/" || true
fi

exec nginx -g "daemon off;"
