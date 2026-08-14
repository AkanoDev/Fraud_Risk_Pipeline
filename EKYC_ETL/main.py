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
    load(clean_df, "staging_ekyc")

    # -------------------------
    # MERGE STAGING -> RAW
    # -------------------------
    run_sql_file("sql/merge_ekyc.sql")

    # -------------------------
    # CREATE BUSINESS TABLE
    # -------------------------
    run_sql_file("sql/ekyc_calculated.sql")

    # -------------------------
    # CREATE SUMMARY TABLES
    # -------------------------
    run_sql_file("sql/ekyc_status_daily.sql")
    run_sql_file("sql/ekyc_duration_daily.sql")
    run_sql_file("sql/ekyc_hourly_submission.sql")
    run_sql_file("sql/ekyc_breakdown_daily.sql")

    print("ETL pipeline completed successfully.")


if __name__ == "__main__":
    run_pipeline()