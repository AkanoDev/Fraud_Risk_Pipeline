"""
Runs a .sql file against Postgres.
"""

from sqlalchemy import text
from load import get_engine


def run_sql_file(filepath: str):
    """Read a .sql file and execute its statements against Postgres."""
    with open(filepath, "r", encoding="utf-8") as f:
        sql_content = f.read()

    engine = get_engine()
    with engine.begin() as conn:  # begin() auto-commits on success
        conn.execute(text(sql_content))

    print(f"Executed SQL file: {filepath}")