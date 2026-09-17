#!/bin/sh
set -eu

: "${CODEX_LB_URL:?Set CODEX_LB_URL to the deployed HTTPS route}"
curl --fail --silent --show-error "${CODEX_LB_URL%/}/health/live" >/dev/null
curl --fail --silent --show-error \
  -H "Authorization: Bearer ${CODEX_LB_API_KEY:?Set CODEX_LB_API_KEY}" \
  "${CODEX_LB_URL%/}/v1/models" >/dev/null
echo "health and authenticated model listing passed"
