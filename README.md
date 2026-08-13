
# ONS Hourly Generation by Power Plant – dbt & DuckDB Pipeline

## 📌 Project Overview

This project processes open data from the **ONS (Operador Nacional do Sistema Elétrico)** regarding **Hourly Power Generation by Plant** (*Geração por Usina em Base Horária*).

The goal is to build an end-to-end ELT/ETL pipeline using **Python** for initial data extraction, **DuckDB** as an embedded OLAP storage engine, and **dbt (data build tool)** for data transformation, testing, lineage management, and documentation.

---

## 📊 Dataset Context

* **Source:** ONS (Operador Nacional do Sistema Elétrico) Open Data Portal
* **Granularity:** Hourly power generation per plant, plant cluster, or group of small power plants.
* **Scope & Grouping:**
  * **2000–2021:** Data files are grouped annually (one file per year).
  * **2022–Present:** Data files are grouped monthly (one file per month/year).
* **Plant Classification Breakdown:**
  * **Type II-C:** Plant sets/clusters established through Operational Adjustments (*Ajustamentos Operativos*), following Submodule 7.2 of the Network Procedures (*Procedimentos de Rede*), available in the MPO.
  * **Type III:** Groups of small power plants that do not interact directly with ONS; data for these represents estimated/forecasted generation.
* **Data Refresh Note:** The source data undergoes recurring consistency processes, meaning historical data may be periodically updated at the source after initial publication.

---

## 🛠️ Tech Stack & Architecture

* **Extraction & Ingestion (Python):** Python scripts handle fetching remote files from ONS, downloading historical annual and monthly batches, and staging initial raw data.
* **Storage & Analytical Engine (DuckDB):** Lightweight, high-performance columnar database used to store raw staging data and power analytical queries locally.
* **Data Transformation (dbt Core + `dbt-duckdb`):**
  * Manages SQL transformations across Staging, Intermediate, and Mart layers.
  * Incorporates **dbt Python models** where complex Python transformations/data manipulation are required within the ETL pipeline.
  * Enforces data quality via automated testing and schema documentation.

---

## 🏗️ Project Architecture & Data Flow

[ ONS Open Data API/Files ]
           │
           ▼
  ┌─────────────────────────────────────────────────────────┐
  │                   dbt Pipeline                          │
  ├─────────────────────────────────────────────────────────┤
  │ 1. models/extract/  (Python Models)                     │
  │    └── Fetches remote CSV/parquet files & writes raw    │
  │                                                         │
  │ 2. models/raw/      (SQL Models)                        │
  │    └── Materializes base tables directly in DuckDB      │
  │                                                         │
  │ 3. models/staging/  (SQL Models)                        │
  │    └── Renames, casts datatypes, and cleans schema     │
  │                                                         │
  │ 4. models/marts/    (SQL Models)                        │
  │    └── Fact & dimension tables for business analysis   │
  └─────────────────────────────────────────────────────────┘
           │
           ▼
    [ DuckDB Storage ]


## 📁 Directory Structure

.
├── analyses/              # Ad-hoc SQL queries (not materialized as models)
├── data/                  # Local storage for raw files or DuckDB database
├── logs/                  # dbt execution logs
├── macros/                # Custom SQL macros
├── models/                # Core dbt transformation pipeline
│   ├── extract/           # Python models (.py) handling data extraction from ONS
│   ├── raw/               # SQL models defining base/landing raw structures
│   ├── staging/           # SQL models for cleaning, renaming & type casting
│   └── marts/             # SQL models for final fact and dimension analytical tables
├── seeds/                 # Static CSV reference files
├── snapshots/             # Slowly Changing Dimensions (SCD Type 2) tracking
├── target/                # dbt compiled code and manifest files
├── tests/                 # Custom data quality tests
├── .gitignore
├── dbt_project.yml        # dbt project configuration
└── README.md
