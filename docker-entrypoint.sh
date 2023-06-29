#!/bin/sh

set -e

chown -R "$(id -u qsign)":"$(id -u qsign)" .

exec gosu qsign sh bin/unidbg-fetch-qsign --port=80 --count="$COUNT" --library=/app/txlib --android_id="$ANDROID_ID" "$@"