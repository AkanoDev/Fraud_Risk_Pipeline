"""
Central configuration for the ETL pipeline.
Reads sensitive values (password, etc.) from a .env file instead of
hardcoding them in the script — keeps credentials out of version control.
"""

import os
from dotenv import load_dotenv

load_dotenv()  # loads variables from a .env file in the same folder

DB_CONFIG = {
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
    "name": os.getenv("DB_NAME"),
}

# Folder where source Excel files live
SOURCE_FOLDER = os.getenv("SOURCE_FOLDER", r"C:\Users\Redick.Taal\OneDrive - DigiPlus Interactive\Desktop\RED\.FRAUD & RISK\00_FraudandRisk_db\SOURCE\PENDING_SOURCE")

# Target table name in Postgres
TABLE_NAME = os.getenv("TABLE_NAME", "pending_clean")
