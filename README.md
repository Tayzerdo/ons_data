
# ONS Hourly Generation by Power Plant — Data Engineering Pipeline

## 📌 Project Overview

This project builds an end-to-end data engineering pipeline using open data from the  **ONS (Operador Nacional do Sistema Elétrico)** .

The main dataset contains  **hourly electricity generation by power plant** , allowing the project to explore electricity generation patterns in Brazil while providing a practical environment to develop and demonstrate data engineering skills.

The project is designed around a modern data pipeline architecture using:

* 🐍 **Python** — data extraction and ingestion
* 🦆 **DuckDB** — local analytical database and raw data storage
* 🔧 **dbt** — data transformation, testing, documentation and lineage
* 🛫 **Airflow** — pipeline orchestration *(planned)*
* 📊 **Tableau** — data visualization and analytics *(planned)*

The project is being developed incrementally, with the objective of eventually creating a fully automated and reproducible pipeline.

---

## 📊 Dataset Context

### Hourly Generation by Power Plant

**Source:** ONS Open Data Portal

**Dataset:**`<span>Geração por Usina em Base Horária</span>`

The dataset contains hourly electricity generation information at plant level, including generation from individual plants, plant clusters and groups of small power plants.

### Data coverage

* **2000–2021:** Files are generally grouped by year.
* **2022–Present:** Files are generally grouped by month.

The ONS source may also perform consistency processes that update historical data after the original publication. Therefore, the ingestion pipeline needs to account for files that may have been modified after their initial ingestion.

### Plant classification

The ONS dataset includes different types of plant/group classifications, including:

* **Type II-C:** Plant sets/clusters established through operational adjustments.
* **Type III:** Groups of small power plants that do not interact directly with ONS; generation data may represent estimated or forecasted generation.

---

# 🏗️ Architecture

The project follows a separation of responsibilities between ingestion, storage and transformation.

```
flowchart TD
    A[☁️ ONS Open Data / S3] --> B[🐍 Python Ingestion]

    B --> C[(🦆 DuckDB)]

    C --> D[🧹 dbt Staging]

    D --> E[📊 dbt Marts]
```
