
# ONS Hourly Generation Data Platform

## 📌 Project Overview

This project builds an end-to-end data pipeline using hourly electricity generation data from the ONS (Operador Nacional do Sistema Elétrico).

The goal is to transform raw ONS data into reliable analytical datasets using a modern data engineering / analytics engineering architecture.

### Tech Stack

* 🐍 **Python** — data extraction and ingestion
* 🦆 **DuckDB** — local raw data storage
* 🔧 **dbt** — data transformation and modeling
* 🛫 **Airflow** — orchestration *(planned)*
* 📊 **Tableau** — visualization *(planned)*

---

# 🏗️ Architecture

```text
ONS Open Data
      │
      ▼
Python Ingestion
      │
      ▼
DuckDB Raw
      │
      ▼
dbt Staging
      │
      ▼
dbt Marts
      │
      ▼
Analytics / Tableau
```

The responsibilities are separated between ingestion, storage and transformation:

* **Python** handles extraction and loading.
* **DuckDB** stores the raw data locally.
* **dbt** transforms the raw data into analytical models.
* **Airflow** will eventually orchestrate the pipeline.

---

# 📊 Data

The main dataset contains hourly electricity generation by power plant.

The ONS data currently covers:

* **2000–2021:** yearly files
* **2022–present:** monthly files

The source data can also be updated historically, which is considered by the ingestion design.

Current raw tables:

```text
raw.generation
raw.modalidade_usina
```

---

# 📐 Data Modeling

The analytical layer currently separates generation measurements from generation entity information.

## Fact: `fct_power_generation`

**Grain:** one generation entity × one hour.

The fact contains:

```text
dtm_power_generation
cod_generation_entity_key
val_power_generation
```

## Dimension: `dim_power_generation_information`

This dimension contains descriptive information about generation entities and preserves historical versions.

A new version is created when descriptive attributes change.

The model contains:

```text
cod_generation_entity_key
id_ons_plant
id_aneel_generation_enterprise
dsc_plant_name
dsc_plant_type
dsc_fuel_type
id_subsystem
dsc_subsystem_name
first_generation
last_generation
is_current
```

### Generation Entity Key

`cod_generation_entity_key` is the analytical key used to connect the generation fact with the generation information dimension.

The key follows this hierarchy:

| Identifier situation | Key                   |
| -------------------- | --------------------- |
| ONS + ANEEL          | ONS + ANEEL           |
| ONS only             | ONS + plant name      |
| ANEEL only           | ANEEL + plant name    |
| Neither              | normalized plant name |

When multiple historical versions exist for the same key, the version with the latest generation timestamp is identified as the current version through `is_current`.

---

# 📁 Project Structure

```text
ons_data/
│
├── data/
├── ingestion/
│
├── models/
│   ├── data_quality/
│   ├── staging/
│   └── marts/
│
├── dags/
├── analyses/
├── macros/
├── seeds/
├── snapshots/
├── tests/
│
├── dbt_project.yml
└── README.md
```

---

# 🚧 Project Roadmap

### ✅ Completed

* ONS S3 data discovery
* Python ingestion structure
* DuckDB raw storage
* Raw generation and production-plant tables
* dbt source configuration
* dbt staging models
* Generation entity key strategy
* Generation fact grain
* Historical generation information dimension
* Current generation entity version identification

### 🚧 In Progress

* Historical generation fact
* Production plant dimension
* dbt tests
* dbt documentation

### 📋 Backlog

* Ingestion change detection
* Generation operational-stage classification
* Airflow orchestration
* Pipeline monitoring and logging
* Tableau dashboards
* CI/CD
* Docker
