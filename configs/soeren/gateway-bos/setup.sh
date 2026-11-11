#!/usr/bin/env bash
# Install Caddy and configure it as an HTTPS gateway to every simpleviz
# instance on this machine, with a self-signed certificate and an Authelia
# login (in a Docker container) in front.
#
# usage: setup.sh [extra-name-or-ip ...]
#
#   extra names/IPs go into the certificate next to GATEWAY_DOMAIN, the
#   hostname, localhost and this machine's addresses (see gen-cert.sh)
#
# Env:
#   GATEWAY_DOMAIN  name the gateway is reached by (default bos.home.arpa, a
#                   home-network name that never resolves publicly, RFC 8375;
#                   must contain a dot). This machine gets an /etc/hosts entry;
#                   other clients need one too (printed at the end).
#   POLICY          one_factor (default) or two_factor (password + TOTP)
#   FORCE=1         regenerate the certificate
#   OFFSET          shifts the public ports (default 1000: 7370-7469 -> 8370-8469)
#   PORTAL_PORT     the login portal's port (default 8360)
#
# Result: https://<domain>:<simpleviz port + OFFSET>/<token>/ reaches the
# simpleviz server on <port> once logged in at https://<domain>:<PORTAL_PORT>;
# one login covers every port. List the URLs with ./gateway-servers.sh.
#
# Writes /etc/caddy/Caddyfile (the previous one is kept as Caddyfile.bak.<time>),
# /etc/caddy/gateway-bos/gateway.{crt,key}, /etc/caddy/gateway-bos/authelia/
# (configuration, logins, secrets made once) and /var/lib/gateway-bos-authelia
# (Authelia's database). On the first run it asks for a login (set-auth.sh;
# add more logins with it later). Needs sudo and docker.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GATEWAY_DOMAIN="${GATEWAY_DOMAIN:-bos.home.arpa}"
export OFFSET="${OFFSET:-1000}" PORTAL_PORT="${PORTAL_PORT:-8360}" POLICY="${POLICY:-one_factor}"
CERT_DIR=/etc/caddy/gateway-bos
CONFIG_DIR="$CERT_DIR/authelia"
DATA_DIR=/var/lib/gateway-bos-authelia
CADDYFILE=/etc/caddy/Caddyfile

if ! command -v caddy >/dev/null; then
  echo "INSTALL caddy"
  omarchy-pkg-add caddy
fi
command -v docker >/dev/null || { echo "setup: docker not found — Omarchy ships it; is this an Omarchy host?" >&2; exit 1; }
# Omarchy enables only docker.socket, so the daemon starts on first use and
# the Authelia container would stay down after a reboot until something
# touches Docker. Starting the daemon at boot brings it back with it; this
# grants no one Docker access (that's the docker group, left untouched).
if ! systemctl is-enabled --quiet docker.service; then
  sudo systemctl enable --now docker.service
  echo "OK    docker.service enabled at boot (for the Authelia container)"
fi

# ---- certificate ----
sudo mkdir -p "$CERT_DIR"
sudo FORCE="${FORCE:-0}" DAYS="${DAYS:-825}" "$SCRIPT_DIR/gen-cert.sh" "$CERT_DIR" "$GATEWAY_DOMAIN" "$@"
# the caddy service user reads the key; nobody else
sudo chown root:caddy "$CERT_DIR/gateway.key"
sudo chmod 640 "$CERT_DIR/gateway.key"
sudo openssl x509 -in "$CERT_DIR/gateway.crt" -noout -checkhost "$GATEWAY_DOMAIN" | grep -q 'does match' \
  || echo "WARN  $CERT_DIR/gateway.crt lacks $GATEWAY_DOMAIN — rerun with FORCE=1"

# ---- Authelia: config, secrets, logins, container ----
# the container runs as caddy and reads these; nobody else may
sudo install -d -m 750 -o root -g caddy "$CONFIG_DIR" "$CONFIG_DIR/secrets"
sudo install -d -m 750 -o caddy -g caddy "$DATA_DIR"
for s in jwt session storage; do
  # made once: a new storage key would make the database unreadable
  if ! sudo test -f "$CONFIG_DIR/secrets/$s"; then
    openssl rand -hex 64 | sudo tee "$CONFIG_DIR/secrets/$s" >/dev/null
    sudo chown root:caddy "$CONFIG_DIR/secrets/$s"
    sudo chmod 640 "$CONFIG_DIR/secrets/$s"
    echo "WROTE $CONFIG_DIR/secrets/$s"
  fi
done
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
"$SCRIPT_DIR/gen-authelia-config.sh" > "$tmp"
sudo install -m 640 -o root -g caddy "$tmp" "$CONFIG_DIR/configuration.yml"
echo "WROTE $CONFIG_DIR/configuration.yml ($GATEWAY_DOMAIN, $POLICY)"
if ! sudo test -s "$CONFIG_DIR/users_database.yml"; then
  echo "AUTH  no login yet — set one now (add or change logins later with ./set-auth.sh)"
  CONFIG_DIR="$CONFIG_DIR" "$SCRIPT_DIR/set-auth.sh"
fi
CONFIG_DIR="$CONFIG_DIR" DATA_DIR="$DATA_DIR" "$SCRIPT_DIR/authelia.sh"

# ---- Caddy ----
"$SCRIPT_DIR/gen-caddyfile.sh" "$CERT_DIR/gateway.crt" "$CERT_DIR/gateway.key" > "$tmp"
chmod 644 "$tmp"
sudo caddy validate --adapter caddyfile --config "$tmp" >/dev/null 2>&1 \
  || { sudo caddy validate --adapter caddyfile --config "$tmp"; exit 1; }

if [[ -f "$CADDYFILE" ]] && ! sudo cmp -s "$tmp" "$CADDYFILE"; then
  backup="$CADDYFILE.bak.$(date +%Y%m%d-%H%M%S)"
  sudo cp -p "$CADDYFILE" "$backup"
  echo "BACKUP $backup"
fi
sudo install -m 644 -o root -g root "$tmp" "$CADDYFILE"
echo "WROTE $CADDYFILE"

sudo systemctl enable caddy >/dev/null 2>&1
if systemctl is-active --quiet caddy; then
  sudo systemctl reload caddy
else
  sudo systemctl start caddy
fi
echo "OK    caddy $(systemctl is-active caddy)"

# home.arpa names never resolve publicly, and the FRITZ!Box can't serve
# custom names: this machine gets a hosts entry, other clients need one too
if ! getent hosts "$GATEWAY_DOMAIN" >/dev/null; then
  printf '127.0.0.1 %s # simpleviz gateway (gateway-bos/setup.sh)\n' "$GATEWAY_DOMAIN" \
    | sudo tee -a /etc/hosts >/dev/null
  echo "WROTE /etc/hosts entry 127.0.0.1 $GATEWAY_DOMAIN"
fi
lan_ip="$(ip -o -4 addr show scope global | awk '{sub(/\/.*/, "", $4); print $4; exit}')"
echo "NOTE  on every other client add to /etc/hosts"
echo "      (Windows: C:\\Windows\\System32\\drivers\\etc\\hosts):"
echo "      $lan_ip $GATEWAY_DOMAIN"
echo "      and trust $CERT_DIR/gateway.crt there, so a certificate warning"
echo "      means something is wrong instead of being routine."
echo "      A fixed IP for this machine (FRITZ!Box: 'Immer die gleiche IPv4-Adresse"
echo "      zuweisen') keeps that line valid."
if command -v ufw >/dev/null && sudo ufw status | grep -q '^Status: active'; then
  echo "NOTE  ufw is active; to reach the gateway from other hosts:"
  echo "      sudo ufw allow $PORTAL_PORT/tcp && sudo ufw allow $(( 7370 + OFFSET )):$(( 7469 + OFFSET ))/tcp"
fi
echo "LOGIN https://$GATEWAY_DOMAIN:$PORTAL_PORT"
