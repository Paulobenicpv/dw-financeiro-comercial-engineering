from pathlib import Path
from sqlalchemy import text
from sqlalchemy.engine import Engine


def execute_transform(engine: Engine, sql_path: str, params: dict):
    statement = Path(sql_path).read_text(encoding="utf-8")
    with engine.begin() as conn:
        conn.execute(text(statement), params)
