# SAP BTP Cloud Foundry deployment

This overlay runs the upstream container on Cloud Foundry. Supply an immutable
registry digest, route, database service name, and database URL through a vars
file before pushing.

## Prerequisites

- Docker image deployment is enabled for the target CF foundation.
- A managed PostgreSQL service instance named `codex-lb-db` exists.
- The image includes the entrypoint with the CF `PORT` patch from this repository.
- `CODEX_LB_ENCRYPTION_KEY_FILE` points to the same secret for every instance.

The manifest intentionally does not use SQLite or the container filesystem for
application data. Set `CODEX_LB_DATABASE_URL` through the PostgreSQL service
binding or the target platform's secret integration. Store the encryption key
the same way and do not commit either value.

## First deployment

```sh
cf target -o <org> -s <space>
cf create-service <postgres-service> <plan> codex-lb-db
cf push -f deploy/cloud-foundry/manifest.yml \
  --vars-file deploy/cloud-foundry/vars.yml
cf logs codex-lb --recent
```

Run database migration once during a controlled release window. After the
initial migration, keep `CODEX_LB_DATABASE_MIGRATE_ON_STARTUP=false` during
rolling deployments and run the migration as a separately reviewed release
step to avoid concurrent migration attempts.

## Validation

```sh
cf app codex-lb
CODEX_LB_URL=https://<route> CODEX_LB_API_KEY=sk-clb-... \
  sh deploy/cloud-foundry/smoke-test.sh
```

Before scaling beyond one instance, verify PostgreSQL-backed sessions,
continuation affinity, API-key ownership, SSE streaming, and WebSocket upgrade
through the CF router. Expose the public route through an authenticated
Application Router when IAS/OIDC is enabled; do not trust user identity headers
from an unrestricted public route.
