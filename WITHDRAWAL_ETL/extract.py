import os
import pandas as pd


def extract_single_file(file_path: str) -> pd.DataFrame:
    """Read one Excel file into a DataFrame."""
    print(f"Reading file: {file_path}")
    df = pd.read_excel(file_path, engine="calamine")
    df["source_filename"] = os.path.basename(file_path)
    return df


def extract_folder(folder_path: str) -> pd.DataFrame:
    """
    Read every .xlsx file in a folder and combine them into one DataFrame.
    Useful if you have multiple daily files to load at once (like your
    per-day subfolder pattern).
    """
    all_files = [
        os.path.join(folder_path, f)
        for f in os.listdir(folder_path)
        if f.lower().endswith(".xlsx") and not f.startswith("~$")
    ]

    if not all_files:
        raise FileNotFoundError(f"No .xlsx files found in {folder_path}")

    frames = [extract_single_file(f) for f in all_files]
    combined = pd.concat(frames, ignore_index=True)

    print(f"Extracted {len(combined)} total rows from {len(all_files)} file(s).")
    return combined
