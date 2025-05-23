# 💼 Layoffs Analysis Project

This project is a structured SQL-based analysis of global tech layoffs, using a dataset sourced from [Kaggle](https://www.kaggle.com/). It is divided into two main parts: **Data Cleaning** and **Exploratory Data Analysis (EDA)**.

## 📂 Project Overview

- **Language/Tools:** MySQL (tested on MySQL 8+)
- **Dataset:** Global Layoffs Dataset from Kaggle
- **Structure:**
  - **Part 1:** Data Cleaning and Standardization
  - **Part 2:** Exploratory Data Analysis (EDA) on Cleaned Data

---

## 📊 Dataset

The dataset contains detailed information about layoffs across the tech industry, including:
- Company name
- Location
- Industry
- Number and percentage of employees laid off
- Funding stage
- Country
- Date of layoffs
- Amount of funding raised

> 📌 Source: [Kaggle – Layoffs Dataset](https://www.kaggle.com/)

---

## 🧹 Part 1 – Data Cleaning (SQL)

In the first phase, we clean and prepare the data for analysis:
- Convert text-based `date` fields to proper `DATE` types
- Standardize values (e.g., normalize country and industry names)
- Handle missing and NULL values
- Identify and remove duplicate rows using `ROW_NUMBER()` and temporary tables

Key SQL concepts used:
- `STR_TO_DATE()`
- `ROW_NUMBER() OVER (PARTITION BY ...)`
- `JOIN`-based updates
- `TRIM()`, `NULL` handling
- `CREATE TEMPORARY TABLE` for deduplication

---

## 📈 Part 2 – Exploratory Data Analysis (EDA)

Once the data is cleaned, we perform SQL-based EDA to uncover trends and insights:
- Total layoffs over time
- Top affected industries and countries
- Funding stages most affected by layoffs
- Company-specific layoff patterns
- Seasonal patterns and peak months

All queries are performed directly in SQL and can be reused or adapted for dashboards or BI tools.

---

## 🛠️ Requirements

- MySQL 8+ (due to use of window functions like `ROW_NUMBER()`)
- Any SQL client (e.g., MySQL Workbench, DBeaver, DataGrip)

---

## 📁 Folder Structure 

```
├── sql/
│ ├── 01_data_cleaning.sql
│ └── 02_eda_queries.sql
├── data/
│ └── layoffs.csv
│ └── cleaned_layoffs.csv
└── README.md
```

---

## 🤝 License

This project is for educational and analytical purposes. Please respect Kaggle's dataset terms of use.

---

## 📬 Contact

If you have questions or ideas, feel free to open an issue or pull request. Contributions welcome!