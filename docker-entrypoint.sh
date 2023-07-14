#!/bin/sh

set -e

if [ "${1#-}" != "$1" ]; then
  set -- bin/unidbg-fetch-qsign "$@"
fi

if [ "$1" = 'bin/unidbg-fetch-qsign' ] && [ "$(id -u)" = '0' ]; then
  chown -R "$(id -u qsign)":"$(id -u qsign)" .
  exec gosu qsign "$@"
fi

um="$(umask)"
if [ "$um" = '0022' ]; then
	umask 0077
fi

exec "$@"
