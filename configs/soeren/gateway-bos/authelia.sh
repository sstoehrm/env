#!/usr/bin/env bash
# (Re)start the gateway's Authelia container.
#
# usage: authelia.sh
#
# Reads configuration.yml, users_database.yml and secrets/ from $CONFIG_DIR
# (default /etc/caddy/gateway-bos/authelia, mounted read-only) and keeps
# its database and notification file in $DATA_DIR (default
# /var/lib/gateway-bos-authelia). Runs as caddy's uid:gid, which may read
# both, and is published on 127.0.0.1:$AUTHELIA_PORT only: Docker-published
# ports bypass ufw, and Caddy is what wraps Authelia in TLS.
#
# Env: CONFIG_DIR, DATA_DIR, AUTHELIA_PORT (default 9091), RUN_AS (uid:gid,
# default caddy's).

set -euo pipefail

IMAGE=authelia/authelia:4.39.28
NAME=gateway-bos-authelia
CONFIG_DIR="${CONFIG_DIR:-/etc/caddy/gateway-bos/authelia}"
DATA_DIR="${DATA_DIR:-/var/lib/gateway-bos-authelia}"
AUTHELIA_PORT="${AUTHELIA_PORT:-9091}"

if [[ -z "${RUN_AS:-}" ]]; then
  id caddy >/dev/null 2>&1 || { echo "authelia.sh: no caddy user — install caddy first (setup.sh)" >&2; exit 1; }
  RUN_AS="$(id -u caddy):$(id -g caddy)"
fi

# Omarchy leaves you out of the docker group (it equals passwordless
# root), so go through sudo unless you opted into sudoless Docker
docker=(docker)
docker info >/dev/null 2>&1 || docker=(sudo docker)

"${docker[@]}" rm -f "$NAME" >/dev/null 2>&1 || true
"${docker[@]}" run -d --name "$NAME" --restart unless-stopped \
  --user "$RUN_AS" \
  --cap-drop ALL --security-opt no-new-privileges \
  -p "127.0.0.1:$AUTHELIA_PORT:9091" \
  -v "$CONFIG_DIR:/config:ro" \
  -v "$DATA_DIR:/data" \
  -e AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE=/config/secrets/jwt \
  -e AUTHELIA_SESSION_SECRET_FILE=/config/secrets/session \
  -e AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE=/config/secrets/storage \
  "$IMAGE" --config /config/configuration.yml >/dev/null

# up once its health endpoint answers; a config error ends it at once
for _ in $(seq 1 40); do
  if curl -s -o /dev/null -f "http://127.0.0.1:$AUTHELIA_PORT/api/health"; then
    echo "OK    $NAME on 127.0.0.1:$AUTHELIA_PORT"
    exit 0
  fi
  [[ "$("${docker[@]}" inspect -f '{{.State.Running}}' "$NAME" 2>/dev/null)" == true ]] || break
  sleep 0.5
done
echo "authelia.sh: $NAME did not come up:" >&2
"${docker[@]}" logs "$NAME" >&2
exit 1
