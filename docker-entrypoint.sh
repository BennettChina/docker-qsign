#!/bin/sh

set -e

chown -R "$(id -u qsign)":"$(id -u qsign)" .

exec gosu qsign sh bin/unidbg-fetch-qsign \
--basePath=/app/txlib \
"$@"