from __future__ import annotations

from sqlalchemy.engine import make_url

from app.db.sqlite_utils import normalize_sqlite_url


def to_sync_database_url(database_url: str) -> str:
    database_url = normalize_sqlite_url(database_url)
    parsed = make_url(database_url)
    driver = parsed.drivername

    if driver == "sqlite+aiosqlite":
        parsed = parsed.set(drivername="sqlite")
    elif driver == "postgresql+asyncpg":
        parsed = parsed.set(drivername="postgresql+psycopg")
        # asyncpg uses ``ssl`` while psycopg/libpq expects ``sslmode``.
        # CF-managed PostgreSQL bindings commonly append ssl=require.
        if "ssl" in parsed.query and "sslmode" not in parsed.query:
            ssl_value = parsed.query["ssl"]
            parsed = parsed.update_query_dict({"sslmode": ssl_value}).difference_update_query(["ssl"])

    return parsed.render_as_string(hide_password=False)
