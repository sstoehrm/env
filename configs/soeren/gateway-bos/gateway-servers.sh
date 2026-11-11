#!/usr/bin/env bash
# List the running simpleviz servers with their gateway URLs.
#
# usage: gateway-servers.sh [domain]
#
# domain defaults to $GATEWAY_DOMAIN or bos.home.arpa, the name
# Authelia's session cookie belongs to (IP URLs don't get a login). OFFSET
# as in setup.sh.

set -euo pipefail

host="${1:-${GATEWAY_DOMAIN:-bos.home.arpa}}"
offset="${OFFSET:-1000}"

simpleviz servers | while read -r url file; do
  if [[ "$url" =~ ^http://localhost:([0-9]+)/([^/]+)$ ]]; then
    port="${BASH_REMATCH[1]}"
    token="${BASH_REMATCH[2]}"
    echo "https://$host:$(( port + offset ))/$token/ $file"
  elif [[ -n "$url" ]]; then
    echo "$url $file"
  fi
done
