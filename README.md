# Predictive Maintenance: Fleet Risk Analysis and Cost Prediction

A end-to-end machine learning portfolio project built on a real-world logistics dataset.
The project demonstrates the full data analytics workflow: SQL fleet analysis, EDA,
feature engineering, classification, regression, clustering, and model interpretation.

---

## Business Problem

A logistics company operates a fleet of vehicles across multiple routes. Unplanned
breakdowns cost far more than scheduled maintenance -- in downtime, repairs, and
missed deliveries. The company needs a data-driven system to answer three questions:

1. **Which vehicles need maintenance?** (binary classification)
2. **How much will that maintenance cost?** (regression)
3. **How can we segment the fleet by risk without labels?** (clustering)

---

## Key Results

| Task | Best Model | Metric | Score |
|------|-----------|--------|-------|
| Maintenance Required (classification) | XGBoost | F1 | see notebook 04 |
| Maintenance Required (classification) | XGBoost | ROC-AUC | see notebook 04 |
| Maintenance Cost (regression) | XGBoost | R2 | see notebook 05 |
| Fleet Segmentation (clustering) | KMeans | Silhouette | see notebook 06 |

Key findings from SHAP analysis:
- The model's top risk drivers align with domain knowledge: usage hours, vehicle age,
  brake condition, and load ratio are the strongest predictors.
- Individual vehicle risk can be explained step-by-step using waterfall plots,
  making model decisions transparent to non-technical stakeholders.
- Unsupervised clustering (no labels) successfully separates high-risk from low-risk
  vehicles based on operational features alone.

---

## Project Structure

```
predictive-maintenance-ml/
|
|-- notebooks/
|   |-- 01_EDA.ipynb                  Exploratory data analysis
|   |-- 02_Fleet_Analysis_SQL.ipynb   SQL-based fleet analysis (inline + .sql files)
|   |-- 03_Feature_Engineering.ipynb  Preprocessing, feature creation, train/test split
|   |-- 04_Classification.ipynb       Maintenance Required prediction (4 models)
|   |-- 05_Regression.ipynb           Maintenance Cost prediction (4 models)
|   |-- 06_Clustering.ipynb           Unsupervised fleet risk segmentation (KMeans)
|   |-- 07_Interpretation.ipynb       SHAP analysis and business recommendations
|
|-- sql/
|   |-- 01_basic_queries.sql          SELECT, WHERE, ORDER BY, LIMIT
|   |-- 02_aggregations.sql           GROUP BY, HAVING, aggregate functions
|   |-- 03_joins_subqueries.sql       INNER/LEFT JOIN, subqueries, multi-table analysis
|   |-- 04_risk_segmentation_cte.sql  CTE-based fleet risk scoring (4-factor model)
|   |-- 05_window_functions.sql       ROW_NUMBER, RANK, NTILE, running totals
|
|-- data/
|   |-- raw/                          Original Kaggle dataset (not tracked by git)
|   |-- processed/                    Train/test splits from notebook 03
|   |-- sql/                          Normalized tables for SQL practice
|
|-- images/                           All chart outputs (numbered 01-39)
|
|-- requirements.txt                  Python dependencies
```

---

## Notebooks

### 01 -- Exploratory Data Analysis
Univariate and bivariate analysis of all 27 features. Target variable distribution,
class imbalance assessment, correlation heatmap, missing value check, and outlier
detection. Business-context annotations on all charts.

### 02 -- Fleet SQL Analysis
SQL analysis of the fleet dataset using Python's `sqlite3` module (results inline)
and standalone `.sql` files in the `sql/` folder. Covers joins, aggregations,
CTEs for multi-step risk scoring, and window functions for ranking and percentile
analysis. Demonstrates dual-mode SQL workflow for portfolio visibility.

### 03 -- Feature Engineering
Data cleaning, leakage detection, and creation of domain-driven features:
`vehicle_age`, `overload_ratio`, `is_overloaded`, `days_since_maintenance`,
`maint_season`. Stratified 80/20 train/test split. Saves processed data to
`data/processed/` for downstream notebooks.

### 04 -- Classification: Maintenance Required Prediction
Binary prediction of `Maintenance_Required`. Models: DummyClassifier (baseline),
Logistic Regression, Random Forest, XGBoost. Handles class imbalance with
`class_weight='balanced'` and `scale_pos_weight`. Evaluates with F1, ROC-AUC,
PR-AUC, and confusion matrices. Includes 5-fold cross-validation on the best model.

### 05 -- Regression: Maintenance Cost Prediction
Predicts `Maintenance_Cost` in dollars. Models: DummyRegressor (baseline),
Linear Regression, Random Forest, XGBoost. Auto log-transforms skewed targets.
Evaluates with RMSE, MAE, R2. Includes residual analysis and actual-vs-predicted
scatter plots. Uses a separate leakage-prevention strategy from notebook 04.

### 06 -- Clustering: Unsupervised Fleet Segmentation
Groups vehicles into risk tiers using KMeans without maintenance labels.
Selects optimal k via Elbow method and Silhouette score. Validates cluster meaning
post-hoc against actual `Maintenance_Required` labels. Visualizes with PCA 2D
projection. Assigns human-readable risk tiers (High/Medium/Low) based on data.

### 07 -- Model Interpretation: SHAP Analysis
Explains XGBoost classifier predictions using SHAP TreeExplainer. Global importance
bar chart, beeswarm plot, dependence plots for top 3 features, and individual
waterfall explanation for the highest-risk vehicle. Feature direction analysis
shows which features increase vs decrease predicted risk. Actionable business
recommendations derived from SHAP findings.

---

## SQL Analysis

Five `.sql` files in the `sql/` folder demonstrate progressive SQL complexity:

| File | Concepts |
|------|---------|
| `01_basic_queries.sql` | SELECT, WHERE, BETWEEN, ORDER BY, LIMIT |
| `02_aggregations.sql` | GROUP BY, HAVING, COUNT, AVG, SUM, ROUND |
| `03_joins_subqueries.sql` | INNER JOIN, LEFT JOIN, subqueries, star schema |
| `04_risk_segmentation_cte.sql` | Multi-step CTEs, CASE WHEN, risk scoring |
| `05_window_functions.sql` | ROW_NUMBER, RANK, NTILE, SUM OVER (running total) |

The database uses a normalized star schema (8 tables) built in notebook 02.

---

## Tech Stack

| Category | Tools |
|----------|-------|
| Language | Python 3.12 |
| Data manipulation | pandas, numpy |
| Machine learning | scikit-learn, xgboost |
| Model interpretation | shap |
| Visualization | matplotlib, seaborn |
| SQL | sqlite3 (in-memory, no server needed) |
| Environment | JupyterLab |

---

## How to Run

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/predictive-maintenance-ml.git
cd predictive-maintenance-ml

# 2. Install dependencies
pip install -r requirements.txt

# 3. Download the dataset from Kaggle and place it in:
#    data/raw/logistics_dataset_with_maintenance_required.csv
#    Dataset: https://www.kaggle.com/datasets/datasetengineer/logistics-vehicle-maintenance-history-dataset

# 4. Run notebooks in order (01 through 07)
jupyter lab
```

> Note: The raw dataset is not included in this repository (92,000 rows, Kaggle CC0 license).
> Download it directly from Kaggle using the link above.

---

## Dataset

- **Source:** [Logistics Vehicle Maintenance History Dataset](https://www.kaggle.com/datasets/datasetengineer/logistics-vehicle-maintenance-history-dataset) (Kaggle, CC0)
- **Size:** 92,000 rows, 27 columns
- **Target variables:** `Maintenance_Required` (binary), `Maintenance_Cost` (continuous)
- **Key features:** Vehicle type, usage hours, load capacity, brake condition, tire condition,
  fuel efficiency, route info, year of manufacture, last maintenance date

---

## Author

Sergey Kasatov
Junior Data Analytics student, MSIT Masterschool
Background: 17 years as automotive engineer

[GitHub](https://github.com/YOUR_USERNAME) | [LinkedIn](https://linkedin.com/in/YOUR_PROFILE)
