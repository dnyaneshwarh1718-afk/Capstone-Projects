import pandas as pd
from sqlalchemy import create_engine, text
from src.config import DB_CONFIG

def get_engine():
    user = DB_CONFIG["user"]
    password = DB_CONFIG["password"]
    host = DB_CONFIG["host"]
    port = DB_CONFIG["port"]
    db = DB_CONFIG["database"]

    url = f"mysql+mysqlconnector://{user}:{password}@{host}:{port}/{db}"
    engine = create_engine(url)
    return engine

def run_sql_file(engine, sql_file_path: str):
    """
    Executes SQL statements from a .sql file
    Supports multiple statements separated by ';'
    """
    with open(sql_file_path, "r", encoding="utf-8") as f:
        sql_script = f.read()

    statements = [s.strip() for s in sql_script.split(";") if s.strip()]

    with engine.begin() as conn:
        for stmt in statements:
            conn.execute(text(stmt))

def load_table(engine, loan_master: str):
    query = f"SELECT *FROM {loan_master};"
    return pd.read_sql(query, engine)
