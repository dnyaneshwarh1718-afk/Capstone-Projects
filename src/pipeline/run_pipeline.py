from src.components.data_ingestion import get_engine, run_sql_file, load_table
from src.config import (
    SQL_CLEANING_PATH,
    SQL_AGG_PATH,
    SQL_MT_PATH,
    MASTER_TABLE_NAME
)

def run_sql_Pipeline():
    engine = get_engine()

    print("Running Data Cleaning SQL..")
    run_sql_file(engine, SQL_CLEANING_PATH)

    print("Running Aggregation SQL..")
    run_sql_file(engine, SQL_AGG_PATH)

    print("Running Master table SQL..")
    run_sql_file(engine, SQL_MT_PATH)

    print("Loading master table: {MASTER_TABLE_NAME}")
    df = load_table(engine, MASTER_TABLE_NAME)

    return df

