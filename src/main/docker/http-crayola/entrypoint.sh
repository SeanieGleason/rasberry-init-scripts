#!/bin/sh

set -e

if [ -z "$TARGET_URL" ]; then
  echo "ERROR: TARGET_URL not set"
  exit 1
fi

# If directory is empty → perform download
if [ -z "$(ls -A /data)" ]; then
  echo "==> Downloading $TARGET_URL from Wayback Machine..."
  wayback_machine_downloader "$TARGET_URL" --all-timestamps --directory /data
  echo "==> Download complete."
else
  echo "==> Download already exists, skipping."
fi

echo "==> Starting HTTP server on port 80..."
# Serve /data as website
exec busybox httpd -f -p 80 -h /data