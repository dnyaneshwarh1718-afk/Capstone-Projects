random_state = 42
test_size = 0.2

target_col = "Status"

binary_map = {"A": 0, "C":0,"B":1,"D":1}

# Database Conncetion 
DB_CONFIG = {
    "host" : "localhost",
    "port": 3306,
    "database" :'capstone_project',
    "user" : "root",
    "password" : "Dnyanesh@123"
}

# SQL file Paths
SQL_CLEANING_PATH = "SQL/Data Cleaning.sql"
SQL_AGG_PATH = "SQL/Aggregation tables.sql"
SQL_MT_PATH = "SQL/Master Table.sql"

MASTER_TABLE_NAME = "loan_master"

#MODLES FILE SAVING PATH
BINARY_MODEL_PATH = "models/binary_model.pkl"
MULTI_MODEL_PATH = "models/binary_model.pkl"
METRICS_PATH = "models/model_metrics.json"