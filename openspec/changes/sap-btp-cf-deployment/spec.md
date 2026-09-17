## Requirements

### Requirement: Cloud Foundry runtime
The deployment SHALL listen on `0.0.0.0` and the port supplied by the
Cloud Foundry `PORT` environment variable.

### Requirement: durable state
The deployment SHALL use an external PostgreSQL database and SHALL NOT rely on
the application container filesystem for durable state.

### Requirement: controlled migrations
The deployment SHALL support running database migrations as a separately
controlled release step before scaling or rolling out application instances.

### Requirement: immutable release
The deployment SHALL reference an immutable container image digest rather than
an unpinned `latest` tag.
