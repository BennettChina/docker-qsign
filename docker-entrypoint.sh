#!/bin/sh

set -e

if [ "${1#-}" != "$1" ]; then
  set -- bin/unidbg-fetch-qsign "$@"
fi

if [ "$1" = 'bin/unidbg-fetch-qsign' ] && [ "$(id -u)" = '0' ]; then
  chown -R "$(id -u qsign)":"$(id -u qsign)" .

  exec gosu qsign sh bin/unidbg-fetch-qsign \
    --basePath=/app/txlib \
    "$@"
fi

exec "$@"
