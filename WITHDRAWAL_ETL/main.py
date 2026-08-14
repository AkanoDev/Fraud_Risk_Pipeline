from db_utils import run_sql_file
from extract import extract_folder, extract_single_file
from transform import transform
from load import load
from config import SOURCE_FOLDER

def run_pipeline(single_file: str = None):

    # -------------------------
    # EXTRACT
    # -------------------------
    if single_file:
        raw_df = extract_single_file(single_file)
    else:
        raw_df = extract_folder(SOURCE_FOLDER)

    # -------------------------
    # TRANSFORM
    # -------------------------
    clean_df = transform(raw_df)

    # -------------------------
    # LOAD TO STAGING
    # -------------------------
    load(clean_df, "staging_withdrawal")

    # -------------------------
    # MERGE STAGING -> RAW
    # -------------------------
    run_sql_file("sql/merge_withdrawal.sql")

    # -------------------------
    # CREATE BUSINESS TABLE
    # -------------------------
    run_sql_file("sql/withdrawal_calculated.sql")

    # -------------------------
    # CREATE SUMMARY TABLES
    # -------------------------
    run_sql_file("sql/wd_status_daily.sql")
    run_sql_file("sql/wd_duration_daily.sql")
    run_sql_file("sql/wd_hourly_order.sql")
    run_sql_file("sql/wd_breakdown_daily.sql")
    run_sql_file("sql/wd_system_monthly_daily.sql")
  
    print("ETL pipeline completed successfully.")


if __name__ == "__main__":
    run_pipeline()
 
