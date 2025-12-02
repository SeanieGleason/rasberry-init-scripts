#!/bin/sh
set -e

# Install dependencies
apk add --no-cache curl jq wget

# Ensure env vars
if [ -z "$TARGET_URL" ] || [ -z "$YEAR" ]; then
  echo "TARGET_URL and YEAR must be set"
  exit 1
fi

echo "==> Fetching latest snapshot for $TARGET_URL in $YEAR..."

# Query Wayback Machine CDX API for the given year, JSON output
json=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$TARGET_URL&to=${YEAR}1231&output=json&fl=original,timestamp&filter=statuscode:200&limit=1&collapse=timestamp:8&sort=reverse")

# The result is an array of arrays; extract timestamp
# Skip header row
timestamp=$(echo "$json" | jq -r '.[1][1]')

# Clean URL
file_url=$(echo "$TARGET_URL" | sed 's/:80//')
wayback_url="https://web.archive.org/web/${timestamp}id_/$file_url"

echo "==> Wayback Machine URL: $wayback_url"

# Download site with wget
if [ -z "$(ls -A /data)" ]; then
  echo "==> Downloading $TARGET_URL via wget..."
  wget  -r -np -k -p -e robots=off "$wayback_url" -P ./data
  echo "==> Download complete."
  echo "==> Moving to nginx index.html dir."

  ls "./data/web.archive.org/web/${timestamp}id_/http:/$file_url/"
  mv "./data/web.archive.org/web/${timestamp}id_/$file_url/" "./data"
  echo "==> Done move."
else
  echo "==> Existing download detected. Skipping wget."
fi