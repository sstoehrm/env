#!/usr/bin/env bash
# Generate a self-signed TLS certificate for the simpleviz gateway.
#
# usage: gen-cert.sh <out-dir> [extra-name-or-ip ...]
#
# The certificate covers this machine's hostname (and <hostname>.local),
# localhost, 127.0.0.1, ::1, every global address from `hostname -I`, and
# any extra DNS names or IPs given as arguments. Writes <out-dir>/gateway.crt
# and <out-dir>/gateway.key; an existing pair is left alone unless FORCE=1.

set -euo pipefail

out_dir="${1:?usage: gen-cert.sh <out-dir> [extra-name-or-ip ...]}"
shift
days="${DAYS:-825}"
crt="$out_dir/gateway.crt"
key="$out_dir/gateway.key"

if [[ -f "$crt" && -f "$key" && "${FORCE:-0}" != 1 ]]; then
  echo "OK    $crt exists (FORCE=1 to regenerate)"
  exit 0
fi

command -v openssl >/dev/null || { echo "gen-cert: openssl not found" >&2; exit 1; }

host="$(hostname)"
names=("$host" "$host.local" localhost)
ips=(127.0.0.1 ::1)
# hostname -I lists every address; skip link-local IPv6 (fe80::)
for a in $(hostname -I 2>/dev/null); do
  [[ "$a" == fe80:* ]] || ips+=("$a")
done
for extra in "$@"; do
  if [[ "$extra" =~ ^[0-9.]+$ || "$extra" == *:* ]]; then ips+=("$extra"); else names+=("$extra"); fi
done

san=""
for n in "${names[@]}"; do san+="DNS:$n,"; done
for i in "${ips[@]}"; do san+="IP:$i,"; done
san="${san%,}"

mkdir -p "$out_dir"
umask 077
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes \
  -days "$days" -subj "/CN=$host simpleviz gateway" \
  -addext "subjectAltName=$san" \
  -addext "basicConstraints=critical,CA:FALSE" \
  -addext "keyUsage=critical,digitalSignature" \
  -addext "extendedKeyUsage=serverAuth" \
  -keyout "$key" -out "$crt" 2>/dev/null
chmod 644 "$crt"

echo "WROTE $crt ($days days)"
echo "      SAN: $san"
