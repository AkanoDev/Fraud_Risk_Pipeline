EXPECTED_COLUMNS = [
    "Status",
    "Locked State",
    "Locked By",
    "Locked Date",
    "Locked Remark",
    "Unlocked By",
    "Unlocked Date",
    "Unlocked Remark",
    "Created Time",
    "Risk Completion Time",
    "Exception Prompt",
    "Type",
    "First Withdrawal",
    "Serial Number",
    "Label",
    "Account",
    "Account ID",
    "Amount",
    "Site Product",
    "Created By",
    "Open Time",
    "Audit By",
    "Assignee Time",
    "Processing Time",
    "Processing By",
    "Process Time",
    "Processed By",
    "Risk Check",
    "Exception Prompt Check",
    "IP Address",
    "Rejection Reason",
    "Remark",
    "source_filename",
]

def validate_columns(df, expected_columns):

    actual_columns = list(df.columns)

    expected_set = set(expected_columns)
    actual_set = set(actual_columns)

    # Columns expected by the ETL but missing from source
    missing_columns = expected_set - actual_set

    # Columns existing in source but not needed by ETL
    unused_columns = actual_set - expected_set

    print("\n" + "=" * 30)
    print("COLUMN VALIDATION")
    print("=" * 30)

    # -----------------------------
    # TARGETED COLUMNS
    # -----------------------------

    print("\nTARGETED COLUMNS")
    print("-" * 30)

    for column in expected_columns:

        if column in actual_set:
            print(f" {column}")
        else:
            print(f" {column} [MISSING]")

    # -----------------------------
    # UNUSED SOURCE COLUMNS
    # -----------------------------

    print("\nUNUSED SOURCE COLUMNS")
    print("-" * 30)

    if unused_columns:
        for column in actual_columns:
            if column in unused_columns:
                print(f" {column}")
    else:
        print("None")

    # -----------------------------
    # RESULT
    # -----------------------------

    print("\n" + "=" * 30)

    if missing_columns:
        print("STATUS: FAILED")
        print("=" * 30)

        raise ValueError(
            "Source file is missing one or more required columns."
        )

    elif unused_columns:
        print("STATUS: PASSED WITH WARNINGS")
    else:
        print("STATUS: PASSED")

    print("=" * 30)

    return True