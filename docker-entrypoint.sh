#!/bin/sh

set -e

if [ "${1#-}" != "$1" ]; then
  set -- bin/unidbg-fetch-qsign "$@"
fi

if [ "$1" = 'bin/unidbg-fetch-qsign' ] && [ "$(id -u)" = '0' ]; then
  find . \! -user qsign -exec chown qsign '{}' +
  exec gosu qsign "$@"
fi

um="$(umask)"
if [ "$um" = '0022' ]; then
	umask 0077
fi

exec "$@"
