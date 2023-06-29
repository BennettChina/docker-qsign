#!/bin/sh

set -e

chown -R "$(id -u qsign)":"$(id -u qsign)" .

exec gosu qsign sh bin/unidbg-fetch-qsign --host=0.0.0.0 --port=80 --count="$COUNT" --library=/app/txlib --android_id="$ANDROID_ID" "$@"