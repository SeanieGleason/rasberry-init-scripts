#!/bin/sh
set -e

if [ -z "$TARGET_URL" ]; then
  echo "ERROR: TARGET_URL not set"
  exit 1
fi

FROM_TS=${FROM_TS:-19960101}
TO_TS=${TO_TS:-19961231}

if [ -z "$(ls -A /data)" ]; then
  echo "==> Downloading $TARGET_URL (1996 snapshots only)..."
  wayback_machine_downloader "$TARGET_URL" \
      --to "$TO_TS" \
      --directory /data

  echo "==> Download complete."

  ls /data/websites

  echo "Attempting curl -mk extraction on local file."
  wget -p -k -E -P downloaded_assets "file://$(pwd)/index.html"
  wget -p -mk -E -P /data/websites "file://data/websites/index.html"

else
  echo "==> Existing download detected. Skipping download."
fi
