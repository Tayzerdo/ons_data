# ONS Hourly Generation Data Platform

## Project Overview

This project builds a data pipeline using hourly electricity generation data from the Brazilian National Electric System Operator (ONS).

The goal is to transform raw public data into reliable analytical datasets using a modern data engineering and analytics engineering architecture.

### Tech Stack

- **Python** — data extraction and ingestion
- **DuckDB** — local data storage
- **dbt** — data transformation, modeling, and testing
- **Airflow** — orchestration (planned)
- **Tableau** — visualization (planned)

---

## Architecture

```text
ONS Open Data
      |
      v
Python Ingestion
      |
      v
DuckDB Raw
      |
      v
dbt Staging
      |
      v
dbt Marts
      |
      v
Analytics / Tableau
```

- **Python** handles source file discovery, extraction, and loading.
- **DuckDB** stores the raw data locally.
- **dbt** transforms raw data into analytical models and validates data quality.
- **Airflow** will eventually orchestrate the pipeline.

---

## Data Sources

The main dataset contains hourly electricity generation by power plant.

**Source:** ONS Open Data — `Geração por Usina em Base Horária`

The data generally uses yearly files for 2000–2021 and monthly files from 2022 onward. Historical source files may also be updated.

Current raw tables:

- `raw.generation`
- `raw.modalidade_usina`

---

## Data Modeling

The analytical layer separates hourly generation measurements from descriptive generation entity information.

### Fact: `fct_power_generation`

**Grain:** one generation entity per hour.

The fact contains:

- `dtm_power_generation`
- `cod_generation_entity_key`
- `val_power_generation`

### Dimension: `dim_power_generation_information`

This dimension stores descriptive information about generation entities and preserves historical versions.

A new version is created when one or more selected descriptive attributes change, including plant name, plant type, or fuel type.

The model includes:

- `cod_generation_entity_key`
- `id_ons_plant`
- `id_aneel_generation_enterprise`
- `dsc_plant_name`
- `dsc_plant_type`
- `dsc_fuel_type`
- `first_generation`
- `last_generation`
- `is_current`

The `is_current` flag identifies the version with the latest observed generation timestamp for each entity key.

### Generation Entity Key

`cod_generation_entity_key` is the analytical key used to connect the generation fact and dimension.

The key follows this hierarchy:

| Identifier availability | Key construction                         |
| ----------------------- | ---------------------------------------- |
| ONS + ANEEL             | ONS identifier + ANEEL identifier        |
| ONS only                | ONS identifier + normalized plant name   |
| ANEEL only              | ANEEL identifier + normalized plant name |
| Neither                 | Normalized plant name                    |

### Production Plant Dimension

The production plant source contains additional information such as operational modality, authorized power, connection point, and ANEEL status.

The initial model and `cod_plant_entity_key` have been created. However, multiple records can share the same key, and the source semantics are not yet fully understood. The model is retained while its grain and relationships are investigated.

---

## Data Quality

dbt tests and SQL-based data quality checks are used to validate the analytical models.

Current validation work includes:

- Required entity keys are not null.
- Generation values are not null in staging.
- The generation entity and timestamp combination is unique.
- Each generation entity has exactly one current dimension version.
- Historical generation coverage is investigated through dedicated completeness checks.

Additional validation will cover fact-to-dimension relationships and historical version consistency.

---

## Project Structure

```text
ons_data/
├── data/
├── ingestion/
├── models/
│   ├── staging/
│   ├── intermediate/
│   ├── marts/
│   └── data_quality/
├── tests/
├── dags/
├── analyses/
├── macros/
├── seeds/
├── snapshots/
├── dbt_project.yml
└── README.md
```

The `data/` directory contains local data artifacts. Generated files and local database files should not be committed unless explicitly required.

---

## Project Goal

## Project Roadmap

### Completed

- Discovered and ingested ONS generation data from S3.
- Created the raw DuckDB tables for generation data and production plant information.
- Configured dbt sources and staging models.
- Implemented the generation entity key strategy using ONS ID, ANEEL ID, and normalized plant names.
- Defined and validated the grain of `fct_power_generation`: one generation entity per hour.
- Implemented `dim_power_generation_information` to track historical changes in selected descriptive attributes.
- Implemented current-version identification for generation entities.
- Added dbt tests for key uniqueness, duplicate generation records, dimension coverage, and current-version consistency.
- Validated generation timestamp completeness through dbt data quality checks.
- Confirmed that every generation entity in the fact table has a corresponding record in the historical information dimension.

### In Progress

- Investigating generation-value quality warnings in staging and the fact table.
- Refining data quality rules to distinguish blocking failures from non-blocking warnings.
- Investigating missing, non-numeric, and negative generation measurements without assuming that missing values represent zero.
- Validating historical generation coverage and documenting the limitations of the source data.
- Reviewing and aligning README documentation with the implemented dbt models and tests.

### Blocked

- **Production plant dimension:** The source grain and relationships between operational configurations, connection points, and plant entities remain unclear. The model is retained while the source semantics are investigated.

### Backlog

- Implement ingestion change detection and handling for historical source-file updates.
- Investigate operational-stage classification and its effect on generation measurements.
- Add Airflow orchestration.
- Improve pipeline logging, monitoring, and failure handling.
- Build Tableau dashboards on top of the validated analytical models.
- Add Docker and CI/CD support.

Build a reproducible and maintainable pipeline that transforms public electricity generation data into reliable analytical datasets, with a focus on data quality, dimensional modeling, and automation.
