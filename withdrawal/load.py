import io
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.types import Numeric, Text, Date, DateTime, Integer

from config import DB_CONFIG

# Postgres column types — must match the columns produced by transform.py
DTYPE_MAP = {
    "status": Text(),
    "locked_state": Text(),
    "locked_by": Text(),
    "locked_date": DateTime(),
    "locked_remark": Text(),

    "unlocked_by": Text(),
    "unlocked_date": DateTime(),
    "unlocked_remark": Text(),
    "created_time": DateTime(),
    "risk_completion_time": DateTime(),
    "exception_prompt": Text(),

    "type": Text(),
    "first_withdrawal": Text(),
    "serial_number": Text(),
    "label": Text(),
    "account": Text(),

    "account_id": Text(),
    "amount": Numeric(12, 2),
    "site_product": Text(),
    "created_by": Text(),
    "open_time": DateTime(),

    "audit_by": Text(),
    "assignee_time": DateTime(),
    "processing_time": DateTime(),
    "processing_by": Text(),
    "process_time": DateTime(),

    "processed_by": Text(),
    "risk_check": Text(),
    "exception_prompt_check": Integer(),
    "ip_address": Text(),
    "rejection_reason": Text(),
    "remark": Text(),

    "exported_date": Date(),
}


def get_engine():
    conn_str = (
        f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['name']}"
    )
    return create_engine(conn_str)

def ensure_table_exists(df: pd.DataFrame, table_name: str, engine):
    """
    Creates the table if it doesn't exist yet
    """
    empty_df = df.iloc[0:0]  # same columns/dtypes, no rows
 
    empty_df.to_sql(
        table_name,
        engine,
        if_exists="append",   
        index=False,
        dtype=DTYPE_MAP,
    )

def load(df: pd.DataFrame, table_name: str):

    engine = get_engine()
    
    total_rows = len(df)

    print(f"Loading {total_rows} rows into '{table_name}'...")

    # Create staging table if it doesn't exist
    ensure_table_exists(df, table_name, engine)

    buffer = io.StringIO()

    df.to_csv(
        buffer,
        index=False,
        header=False,
        na_rep=""
    )

    buffer.seek(0)

    raw_conn = engine.raw_connection()

    try:

        cursor = raw_conn.cursor()

        # Empty staging before each load
        cursor.execute(f"TRUNCATE TABLE {table_name};")

        columns = ", ".join(df.columns)

        copy_sql = f"""
        COPY {table_name} ({columns})
        FROM STDIN
        WITH (
            FORMAT csv,
            NULL ''
        )
        """

        cursor.copy_expert(copy_sql, buffer)

        raw_conn.commit()

    except Exception:

        raw_conn.rollback()
        raise

    finally:

        raw_conn.close()

    print(f"Loaded {total_rows} rows into '{table_name}'.")