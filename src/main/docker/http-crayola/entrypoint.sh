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

  echo "Attempting curl -mk extraction on local file."
  cd ./data/websites/www.crayola.com
  curl -mk file:///www.crayola.com/index.html

else
  echo "==> Existing download detected. Skipping download."
fi
