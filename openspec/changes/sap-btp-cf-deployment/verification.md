# Deployment verification

- Image build run 35186734328 succeeded for commit 478179e4.
- GHCR linux/amd64 image: `sha256:3107cd80b9ca63f4d2d52895ad113b2d8d3e96f12dc063a95af8a023594b2d95`.
- CF `diego_docker` is enabled in the targeted jp10 foundation.
- `codex-lb-db` reports create succeeded, offering postgresql-db, plan free.
- Earlier scanner failures were image reference errors, not vulnerability results:
  owner casing and a full-SHA tag differed from the published lowercase short-SHA tag.
- Scan workflow now accepts only this repository's immutable digest, passes registry
  credentials through environment variables, and fails for fixable HIGH/CRITICAL findings.
- Live application deployment, database migrations, IAS, and streaming tests remain pending.
