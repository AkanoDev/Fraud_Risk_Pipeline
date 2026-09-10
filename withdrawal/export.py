import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from config import DB_CONFIG   

def get_connection():
    connection_string = (
        f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['name']}"
    )
    return create_engine(connection_string)

def export_query(query, filename="output.xlsx"):
    connection = get_connection()
    data = pd.read_sql(sql=query, con=connection)

    download_path = Path.home() / "Downloads" / filename
    data.to_excel(download_path, index=False)

    print(f"Exported {len(data)} rows to {download_path}")
    return data

def main():
    query = """
        SELECT *
        FROM withdrawal_calculated
        WHERE duration_seconds >= 180
        AND exported_date BETWEEN '2026-09-01' AND '2026-09-07';
    """
    export_query(query, filename="exception_report.xlsx")

if __name__ == "__main__":
    main()