import re
import pandas as pd

COLUMN_MAP = {
    "Status": "status",
    "Locked State": "locked_state",
    "Locked By": "locked_by",
    "Locked Date": "locked_date",
    "Locked Remark": "locked_remark",

    "Unlocked By": "unlocked_by",
    "Unlocked Date": "unlocked_date",
    "Unlocked Remark": "unlocked_remark",
    "Created Time": "created_time",
    "Risk Completion Time": "risk_completion_time",
    "Exception Prompt": "exception_prompt",

    "Type": "type",
    "First Withdrawal": "first_withdrawal",
    "Serial Number": "serial_number",
    "Label": "label",
    "Account": "account",

    "Account ID": "account_id",
    "Amount": "amount",
    "Site Product": "site_product",
    "Created By": "created_by",
    "Open Time": "open_time",

    "Audit By": "audit_by",
    "Assignee Time": "assignee_time",
    "Processing Time": "processing_time",
    "Processing By": "processing_by",
    "Process Time": "process_time",

    "Processed By": "processed_by",
    "Risk Check": "risk_check",
    "Exception Prompt Check": "exception_prompt_check",
    "IP Address": "ip_address",
    "Rejection Reason": "rejection_reason",
    "Remark": "remark",

    "source_filename": "source_filename",
}

def select_and_rename(df: pd.DataFrame) -> pd.DataFrame:
    """Keep only the mapped columns, in order, and rename them."""

    # Add missing columns and fill with NULL (None)
    missing = [col for col in COLUMN_MAP if col not in df.columns]

    if missing:
        print(f"Warning: Missing columns found. Filling with NULL: {missing}")

        for col in missing:
            df[col] = None

    # Keep only the expected columns in the correct order
    df = df[list(COLUMN_MAP.keys())]

    # Rename to database column names
    df = df.rename(columns=COLUMN_MAP)

    return df


def clean_and_cast(df: pd.DataFrame) -> pd.DataFrame:
    """
    Force each column into the correct pandas dtype.
    """
    df["status"] = df["status"].astype(str)
    df["locked_state"] = df["locked_state"].astype(str)
    df["locked_by"] = df["locked_by"].astype(str)
    df["locked_date"] = pd.to_datetime(df["locked_date"], errors="coerce")
    df["locked_remark"] = df["locked_remark"].astype(str)

    df["unlocked_by"] = df["unlocked_by"].astype(str)
    df["unlocked_date"] = pd.to_datetime(df["unlocked_date"], errors="coerce")
    df["unlocked_remark"] = df["unlocked_remark"].astype(str)
    df["created_time"] = pd.to_datetime(df["created_time"], errors="coerce")
    df["risk_completion_time"] = pd.to_datetime(df["risk_completion_time"], errors="coerce")
    df["exception_prompt"] = df["exception_prompt"].astype(str)

    df["type"] = df["type"].astype(str)
    df["first_withdrawal"] = df["first_withdrawal"].astype(str)
    df["serial_number"] = df["serial_number"].astype(str)
    df["label"] = df["label"].astype(str)
    df["account"] = df["account"].astype(str)

    df["account_id"] = df["account_id"].astype(str)
    df["amount"] = pd.to_numeric(df["amount"], errors="coerce")
    df["site_product"] = df["site_product"].astype(str)
    df["created_by"] = df["created_by"].astype(str)
    df["open_time"] = pd.to_datetime(df["open_time"], errors="coerce")

    df["audit_by"] = df["audit_by"].astype(str)
    df["assignee_time"] = pd.to_datetime(df["assignee_time"], errors="coerce")
    df["processing_time"] = pd.to_datetime(df["processing_time"], errors="coerce")
    df["processing_by"] = df["processing_by"].astype(str)
    df["process_time"] = pd.to_datetime(df["process_time"], errors="coerce")

    df["processed_by"] = df["processed_by"].astype(str)
    df["risk_check"] = df["risk_check"].astype(str)
    df["exception_prompt_check"] = (pd.to_numeric(df["exception_prompt_check"], errors="coerce").astype("Int64"))
    df["ip_address"] = df["ip_address"].astype(str)
    df["rejection_reason"] = df["rejection_reason"].astype(str)
    df["remark"] = df["remark"].astype(str)

    # df["exported_date"] = df["created_time"].dt.date
    def extract_date_from_filename(filename):
        match = re.search(r'(\d{2}-\d{2}-\d{4})', filename)
        if match:
            return pd.to_datetime(match.group(1), format="%m-%d-%Y").date()
        return None

    df["exported_date"] = df["source_filename"].apply(extract_date_from_filename)

    return df


def transform(df: pd.DataFrame) -> pd.DataFrame:
    """Run the full transform pipeline: select/rename, then clean/cast."""
    df = select_and_rename(df)
    df = clean_and_cast(df)

    # Report any rows that failed conversion (now NaN) so you can review them
    bad_rows = df[df["amount"].isna() | df["created_time"].isna()]
    if not bad_rows.empty:
        print(f"WARNING: {len(bad_rows)} row(s) had invalid amount/date values.")

    return df
