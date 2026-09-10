import re
import pandas as pd

COLUMN_MAP = {
    "Bill No": "bill_no",
    "Account": "account",
    "Account ID": "account_id",
    "VIP Level": "vip_level",
    "Created Date": "created_date",

    "Created By": "created_by",
    "Info Time": "info_time",
    "Status": "status",
    "Full Name": "full_name",
    "Processed By": "processed_by",
    "Rejection Reason": "rejection_reason",

    "Remark": "remark",
    "Product": "product",
    "Bloodline": "bloodline",
    "Channel": "channel",
    "Manual Reason": "manual_reason",

    "ID Type": "id_type",
    "ID No": "id_no",
    "Is Same User": "is_same_user",
    "Matched User": "matched_user",
    "Nationality": "nationality",
    "Transaction ID": "transaction_id",

    "Risk Start Time": "risk_start_time",
    "CS Start Time": "cs_start_time",
    "CS Completion Time": "cs_completion_time",
    "Risk Completion Time": "risk_completion_time",
    "Result Date": "result_date",

    "Result": "result",
    "Update Date": "update_date",
    "Update By": "update_by",
    "CS Pre-review By": "cs_pre_review_by",
    "CS Pre-review Time": "cs_pre_review_time",
    "Provider Type": "provider_type",

    "eKYC Version": "ekyc_version",
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

    df["bill_no"] = df["bill_no"].astype(str)
    df["account"] = df["account"].astype(str)
    df["account_id"] = df["account_id"].astype(str)
    df["vip_level"] = df["vip_level"].astype(str)
    df["created_date"] = pd.to_datetime(df["created_date"], errors="coerce")

    df["created_by"] = df["created_by"].astype(str)
    df["info_time"] = pd.to_datetime(df["info_time"], errors="coerce")
    df["status"] = df["status"].astype(str)
    df["full_name"] = df["full_name"].astype(str)
    df["processed_by"] = df["processed_by"].astype(str)
    df["rejection_reason"] = df["rejection_reason"].astype(str)

    df["remark"] = df["remark"].astype(str)
    df["product"] = df["product"].astype(str)
    df["bloodline"] = df["bloodline"].astype(str)
    df["channel"] = df["channel"].astype(str)
    df["manual_reason"] = df["manual_reason"].astype(str)

    df["id_type"] = df["id_type"].astype(str)
    df["id_no"] = df["id_no"].astype(str)
    df["is_same_user"] = (pd.to_numeric(df["is_same_user"], errors="coerce").astype("Int64"))
    df["matched_user"] = df["matched_user"].astype(str)
    df["nationality"] = df["nationality"].astype(str)
    df["transaction_id"] = df["transaction_id"].astype(str)

    df["risk_start_time"] = pd.to_datetime(df["risk_start_time"], errors="coerce")
    df["cs_start_time"] = pd.to_datetime(df["cs_start_time"], errors="coerce")
    df["cs_completion_time"] = pd.to_datetime(df["cs_completion_time"], errors="coerce")
    df["risk_completion_time"] = pd.to_datetime(df["risk_completion_time"], errors="coerce")
    df["result_date"] = pd.to_datetime(df["result_date"], errors="coerce")

    df["result"] = df["result"].astype(str)
    df["update_date"] = pd.to_datetime(df["update_date"], errors="coerce")
    df["update_by"] = df["update_by"].astype(str)
    df["cs_pre_review_by"] = df["cs_pre_review_by"].astype(str)
    df["cs_pre_review_time"] = pd.to_datetime(df["cs_pre_review_time"], errors="coerce")
    df["provider_type"] = df["provider_type"].astype(str)

    df["ekyc_version"] = df["ekyc_version"].astype(str)

    # Date-only columns
    def extract_date_from_filename(filename):
        match = re.search(r'(\d{4}-\d{2}-\d{2})', filename)
        if match:
            return pd.to_datetime(match.group(1)).date()
        return None

    df["exported_date"] = df["source_filename"].apply(extract_date_from_filename)

    return df

def transform(df: pd.DataFrame) -> pd.DataFrame:
    """Run the full transform pipeline: select/rename, then clean/cast."""
    df = select_and_rename(df)
    df = clean_and_cast(df)

    bad_rows = df[df["created_date"].isna() | df["info_time"].isna()]
    if not bad_rows.empty:
        print(f"WARNING: {len(bad_rows)} row(s) had invalid date values.")

    return df
