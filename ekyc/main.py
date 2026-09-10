import time
from db_utils import run_sql_file
from extract import extract_folder, extract_single_file
from transform import transform
from load import load
from config import SOURCE_FOLDER
from validation import validate_columns, EXPECTED_COLUMNS

def run_pipeline(single_file: str = None):
    pipeline_start = time.perf_counter()
    # -------------------------
    # EXTRACT
    # -------------------------
    start = time.perf_counter()

    if single_file:
        raw_df = extract_single_file(single_file)
    else:
        raw_df = extract_folder(SOURCE_FOLDER)
    print(f"EXTRACT: {time.perf_counter() - start:.2f} seconds")

    # -------------------------
    # VALIDATE COLUMN HEADERS
    # -------------------------
    start = time.perf_counter()

    validate_columns(raw_df, EXPECTED_COLUMNS)

    print(f"VALIDATION: {time.perf_counter() - start:.2f} seconds")
    
    # -------------------------
    # TRANSFORM
    # -------------------------
    start = time.perf_counter()

    clean_df = transform(raw_df)    

    print(f"TRANSFORM: {time.perf_counter() - start:.2f} seconds")

    # -------------------------
    # LOAD TO STAGING
    # -------------------------

    start = time.perf_counter()

    load(clean_df, "staging_ekyc")

    print(f"LOAD: {time.perf_counter() - start:.2f} seconds")

    # -------------------------
    # MERGE STAGING -> RAW
    # -------------------------
    start = time.perf_counter()

    run_sql_file("sql/merge_ekyc.sql")

    print(f"MERGE: {time.perf_counter() - start:.2f} seconds")

    # -------------------------
    # CREATE BUSINESS TABLE
    # -------------------------
    start = time.perf_counter()

    run_sql_file("sql/ekyc_calculated.sql")

    print(f"CALCULATED: {time.perf_counter() - start:.2f} seconds")

    # -------------------------
    # CREATE SUMMARY TABLES
    # -------------------------
    start = time.perf_counter()
    run_sql_file("sql/ekyc_status_daily.sql")
    print(f"EKYC STATUS DAILY: {time.perf_counter() - start:.2f} seconds")

    start = time.perf_counter()
    run_sql_file("sql/ekyc_duration_daily.sql")
    print(f"EKYC DURATION DAILY: {time.perf_counter() - start:.2f} seconds")

    start = time.perf_counter()
    run_sql_file("sql/ekyc_hourly_submission.sql")
    print(f"EKYC HOURLY SUBMISSION: {time.perf_counter() - start:.2f} seconds")

    start = time.perf_counter()
    run_sql_file("sql/ekyc_breakdown_daily.sql")
    print(f"EKYC BREAKDOWN DAILY: {time.perf_counter() - start:.2f} seconds")

    print("ETL pipeline completed successfully.")


if __name__ == "__main__":
    run_pipeline()