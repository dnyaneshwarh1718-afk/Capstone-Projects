## End-to-End Loan Risk Prediction Pipeline (Czech Bank Dataset) 

## Summary
This project builds an end-to-end loan risk prediction pipeline using the Czech Bank Financial dataset.  
The solution integrates raw banking tables into a **loan-level master dataset** using SQL ETL and applies **business-focused EDA + machine learning** to predict loan repayment risk.

The output can be used to support:
- Risk-based underwriting
- Early warning signals for delinquency
- Portfolio risk monitoring** by customer segment and region

---

## Business Objective
Banks face direct loss when loans are not repaid. The goal is to predict **loan risk** from historical account behavior and customer context.

### Primary Goal
Predict loan outcome using the target column:

- `status` ∈ {A, B, C, D}

Where (as per dataset documentation):
- **A**: Contract finished, loan paid ✅
- **B**: Contract finished, loan not paid ❌
- **C**: Contract running, loan being paid ✅
- **D**: Contract running, loan in debt ❌

### Business Risk Label (Optional Binary Form)
For risk scoring and operational decisioning, the multi-class target can be mapped to binary:
- **Non-default / Good** = {A, C}
- **Default / Risky**   = {B, D}

This binary mapping helps produce a single **risk probability** that can be used for:
- approval thresholds
- manual review routing
- collection prioritization

---

## Data Sources (Raw Tables)
The master dataset is built using the following raw tables:

- `account` – account metadata and frequency
- `client` – customer profile attributes
- `disp` – account-client relationship mapping
- `orders` – permanent orders/payment instructions
- `transaction_data` – transactional activity and balances
- `loan` – loan details and target label
- `card` – card ownership and type
- `district` – regional socioeconomic indicators

---

## Master Table (SQL ETL)
### Grain
✅ **1 row per loan** (loan-level observation)

### Why a Master Table?
Raw banking datasets are normalized and split by business entities.  
For analytics and ML, we require a single denormalized table that combines:
- loan details
- account behavior aggregates
- customer linkage
- district risk factors

### ETL Notes (High-level)
The SQL query:
- uses `loan` as the base table
- joins account and client context via `account_id` and `disp`
- aggregates transactions to generate behavioral features
- aggregates orders and card ownership features
- enriches with district demographic signals

This design prevents join explosion by enforcing correct dataset grain.

---

## Exploratory Data Analysis (Business-Focused)
The EDA is structured to answer 3 questions:

### 1) What is happening in the data?
- dataset shape and feature types
- basic distribution checks for numeric and categorical variables
- target distribution for `status` (class imbalance awareness)

### 2) What is wrong in the data?
- missing values and handling strategy (imputation + missing flags)
- duplicates and loan-level grain validation
- outliers (validated as possible high-risk or high-value behaviors)
- datatype consistency (dates, numeric fields)
- leakage checks to ensure modeling is production-valid

### 3) What matters in the data?
- feature vs target relationships (risk drivers)
- correlation/multicollinearity screening
- region-level risk segmentation using demographic features
- time-based patterns where applicable

---

## Modeling Approach
### Problem Type
- Primary: **Multi-class classification** (A/B/C/D)
- Business deployment option: **Binary risk classification** (default vs non-default)

### Baseline Models
- Logistic Regression (interpretable baseline)
- Tree-based models (Random Forest / Gradient Boosting / XGBoost) for non-linear behavioral patterns

### Evaluation Strategy
Due to class imbalance, model performance is assessed using:
- Macro / Weighted F1 (multi-class)
- Recall on risky classes (B/D)
- PR-AUC (binary default mapping)
- Confusion matrix to control false negatives (missing risky loans)

Threshold tuning is recommended for business deployment.

---

## Production-Ready Preprocessing
A Scikit-learn Pipeline is used to ensure reproducibility and deployment readiness:
- Numeric: median imputation + scaling
- Categorical: frequent imputation + OneHotEncoder(handle_unknown="ignore")
- Model training bundled into a single pipeline artifact

This enables consistent preprocessing across training and inference.

---

## Key SQL Checks (Loan Table)
```sql
-- Total loans
SELECT COUNT(*) AS total_loans FROM loan;

-- Status distribution
SELECT status, COUNT(*) AS loan_count
FROM loan
GROUP BY status
ORDER BY loan_count DESC;

-- Default-like count (B + D)
SELECT COUNT(*) AS default_loans
FROM loan
WHERE status IN ('B','D');


Loan details
Client + Account mapping
Transaction behavior features
Order and card features
Demographic district features 
Problem Statement
