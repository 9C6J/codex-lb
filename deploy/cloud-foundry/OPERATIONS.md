# CF release operations

Each release records the upstream commit, image digest, database migration
result, and staging smoke-test result. Promote the same image digest from
staging to production; rebuilds during promotion are not allowed.

## Release order

1. Build and scan the image in CI and record its digest.
2. Deploy one staging instance with PostgreSQL and the fixed encryption key.
3. Run `/health`, model listing, Responses JSON, SSE, WebSocket, API-key,
   restart, and multi-user isolation checks.
4. Run the database migration once as a controlled release step.
5. Deploy the immutable digest to production with one instance.
6. Verify logs and usage accounting, then scale out only after shared state is
   confirmed.

## Rollback

Redeploy the previous image digest only when its database schema is compatible
with the current migration state. Never roll back by changing a mutable image
tag. If a migration is not backward compatible, follow its documented forward
recovery procedure instead of downgrading the database by hand.
