EXPECTED_COLUMNS = [
    "Bill No",
    "Account",
    "Account ID",
    "VIP Level",
    "Created Date",
    "Created By",
    "Info Time",
    "Status",
    "Full Name",
    "Processed By",
    "Rejection Reason",
    "Remark",
    "Product",
    "Bloodline",
    "Channel",
    "Manual Reason",
    "ID Type",
    "ID No",
    "Is Same User",
    "Matched User",
    "Nationality",
    "Transaction ID",
    "Risk Start Time",
    "CS Start Time",
    "CS Completion Time",
    "Risk Completion Time",
    "Result Date",
    "Result",
    "Update Date",
    "Update By",
    "CS Pre-review By",
    "CS Pre-review Time",
    "Provider Type",
    "eKYC Version",
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