import re
import pandas as pd

COLUMN_MAP = {
    "Serial Number" : "serial_number",
    "Account" : "account",
    "Account ID" : "account_id",
    "User Level" : "user_level",
    "Amount" : "amount",
    "First Withdrawal" : "first_withdrawal",
    "Old Label" : "old_label",
    "Label" : "label",
    "Site Product" : "site_product",
    "Withdraw Time" : "withdraw_time",
    "Type" : "type",
    "Exception Prompt" : "exception_prompt",
    "Rule No" : "rule_no",
    "IP Address" : "ip_address",
    "User Source" : "user_source",
    "Remark" : "remark",
    "Created Date" : "created_date",
    "Processed By" : "processed_by",
    "Processing Time" : "processing_time",
    "Hit the Rule" : "hit_the_rule",
    "Processing Status" : "processing_status",
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

    df["serial_number"] = df["serial_number"].astype(str)
    df["account"] = df["account"].astype(str)
    df["account_id"] = df["account_id"].astype(str)
    df["user_level"] = df["user_level"].astype(str)
    df["amount"] = df["amount"].str.replace(",", "", regex=False).astype(float)
    df["first_withdrawal"] = df["first_withdrawal"].astype(str)
    df["old_label"] = df["old_label"].astype(str)
    df["label"] = df["label"].astype(str)
    df["site_product"] = df["site_product"].astype(str)
    df["withdraw_time"] = pd.to_datetime(df["withdraw_time"], errors="coerce")
    df["type"] = df["type"].astype(str)
    df["exception_prompt"] = df["exception_prompt"].astype(str)
    df["rule_no"] = df["rule_no"].astype(str)
    df["ip_address"] = df["ip_address"].astype(str)
    df["user_source"] = df["user_source"].astype(str)
    df["remark"] = df["remark"].astype(str)
    df["created_date"] = pd.to_datetime(df["created_date"], errors="coerce")
    df["processed_by"] = df["processed_by"].astype(str)
    df["processing_time"] = pd.to_datetime(df["processing_time"], errors="coerce")
    df["hit_the_rule"] = df["hit_the_rule"].astype(str)
    df["processing_status"] = df["processing_status"].astype(str)

    # Date-only columns
    def extract_date_from_filename(filename):
        match = re.search(r'(\d{2}-\d{2}-\d{4})', filename)
        if match:
            return pd.to_datetime(match.group(1)).date()
        return None

    df["exported_date"] = df["source_filename"].apply(extract_date_from_filename)

    return df

def transform(df: pd.DataFrame) -> pd.DataFrame:
    """Run the full transform pipeline: select/rename, then clean/cast."""
    df = select_and_rename(df)
    df = clean_and_cast(df)

    bad_rows = df[df["created_date"].isna() | df["processing_time"].isna()]
    if not bad_rows.empty:
        print(f"WARNING: {len(bad_rows)} row(s) had invalid date values.")

    return df
