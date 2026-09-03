import io
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.types import Numeric, Text, Date, DateTime, Integer

from config import DB_CONFIG

DTYPE_MAP = {
        "serial_number": Text(),
    "account": Text(),
    "account_id": Text(),
    "user_level": Text(),
    "amount": Numeric(),
    "first_withdrawal": Text(),
    "old_label": Text(),
    "label": Text(),
    "site_product": Text(),
    "withdraw_time": DateTime(),
    "type": Text(),
    "exception_prompt": Text(),
    "rule_no": Text(),
    "ip_address": Text(),
    "user_source": Text(),
    "remark": Text(),

    "created_date": DateTime(),
    "processed_by": Text(),
    "processing_time": DateTime(),
    "hit_the_rule": Text(),
    "processing_status": Text(),

    "source_filename": Text(),

    # Calculated columns
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
    Creates the table only if it does not exist.
    """
    empty_df = df.iloc[0:0]

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