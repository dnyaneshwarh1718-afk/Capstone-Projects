import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer

def build_Preprocessor(df: pd.DataFrame, target_col: str):
    x = df.drop(columns = [target_col])

    num_cols = x.select_dtypes(include = ['int64','float64']).columns.tolist()
    cat_cols = x.select_dtypes(include = ['object']).columns.tolist()

    numeric_pipline = Pipeline(steps=[
        ("imputer", SimpleImputer(strategy = "median")),
        ("Scaler", StandardScaler())
    ])

    categorical_pipeline = Pipeline(steps=[
        ("imputer", SimpleImputer(strategy = "most_frequent")),
        ("onehot",OneHotEncoder(handle_unknown="ignore"))
    ])

    preprocessor = ColumnTransformer(
        transformers = [
            ("num",numeric_pipline,num_cols),
            ("cat", categorical_pipeline, cat_cols)
        ]
    )

    return preprocessor

def split_data(df: pd.DataFrame, target_col: str, test_size: float, random_state: int):
    x = df.drop(columns = [target_col])
    y = df[target_col]

    return train_test_split(
        x,y,
        test_size= test_size,
        random_state=random_state,
        stratify=y
    )