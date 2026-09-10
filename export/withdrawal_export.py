import sys
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine

# Add project root (00_FraudAndRisk_DB) to path so `withdrawal` package is importable
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.append(str(PROJECT_ROOT))

from withdrawal.config import DB_CONFIG


def get_connection():
    connection_string = (
        f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['name']}"
    )
    return create_engine(connection_string)


def load_query(name: str) -> str:
    """Load a .sql file's contents from the query/ folder (sibling of export/)."""
    return (PROJECT_ROOT / "query" / name).read_text(encoding="utf-8")


def export_query(query: str, filename: str = "output.xlsx") -> pd.DataFrame:
    connection = get_connection()
    data = pd.read_sql(sql=query, con=connection)

    download_path = Path.home() / "Downloads" / filename
    data.to_excel(download_path, index=False)

    print(f"Exported {len(data)} rows to {download_path}")
    return data


def main():
    query = load_query("wd-more-than-equal-3mins.sql")
    export_query(query, filename="exception_report.xlsx")


if __name__ == "__main__":
    main()