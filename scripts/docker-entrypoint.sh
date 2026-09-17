#!/bin/sh
set -eu

if [ -n "${CODEX_LB_ENCRYPTION_KEY_B64:-}" ]; then
  key_file="${CODEX_LB_ENCRYPTION_KEY_FILE:-/var/lib/codex-lb/encryption.key}"
  mkdir -p "$(dirname "$key_file")"
  printf '%s' "$CODEX_LB_ENCRYPTION_KEY_B64" | base64 -d > "$key_file"
  chmod 600 "$key_file"
fi

if [ "${CODEX_LB_DATABASE_MIGRATE_ON_STARTUP:-true}" = "true" ]; then
  python -m app.db.migrate upgrade
fi

# Disable app-level startup migration so app/db/session.py init_db() does not
# run migrations again inside the app process.
export CODEX_LB_DATABASE_MIGRATE_ON_STARTUP=false

exec python -m app.cli --host 0.0.0.0 --port "${PORT:-2455}"
