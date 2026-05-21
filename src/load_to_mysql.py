import os
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

project_root = Path(__file__).resolve().parents[1]
processed_folder = project_root / "data" / "processed"

db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")

engine = create_engine(
    f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
)

files_to_load = {
    "clean_trips": "clean_trips.csv",
    "clean_weather_hourly": "clean_weather_hourly.csv",
    "station_hourly_flow": "station_hourly_flow.csv",
    "station_risk_summary": "station_risk_summary.csv",
}

for table_name, file_name in files_to_load.items():
    file_path = processed_folder / file_name
    print(f"Loading {file_name} into {table_name}...")

    df = pd.read_csv(file_path)

    df.to_sql(
        name=table_name,
        con=engine,
        if_exists="append",
        index=False,
        chunksize=10000,
        method="multi"
    )

    print(f"Loaded {len(df)} rows into {table_name}")

print("All processed files loaded into MySQL.")