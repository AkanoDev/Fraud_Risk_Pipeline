# Fraud & Risk ETL Pipeline

An ETL (Extract, Transform, Load) pipeline designed to process and prepare **Fraud & Risk operational data** for reporting and analysis.

The project currently contains pipelines for:

- **eKYC**
- **Withdrawal**

The processed data is stored in **PostgreSQL** and structured into calculated and summary tables that can be consumed by **Power BI** and other reporting tools.

---

## 📌 Project Overview

The main purpose of this project is to automate the processing of daily operational Excel files and transform them into structured datasets for analytics.

The general workflow is:

```
Excel Source Files
       │
       ▼
   Extraction
       │
       ▼
   Transformation
       │
       ▼
   Raw / Clean Table
       │
       ▼
   Calculated Table
       │
       ▼
   Daily Summary Tables
       │
       ▼
     Power BI
