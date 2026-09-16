import pandas as pd
from sqlalchemy import text
from sqlalchemy.engine import Engine


def extract_incremental(engine: Engine, spec: dict, watermark=None) -> pd.DataFrame:
    schema = spec.get("source_schema", "public")
    table = spec["source_table"]
    columns = spec["columns"]
    wm_col = spec.get("watermark_column")

    select_list = ", ".join(f'"{c}"' for c in columns)
    sql = f'SELECT {select_list} FROM "{schema}"."{table}"'
    params = {}
    if watermark is not None and wm_col:
        sql += f' WHERE "{wm_col}" > :watermark'
        params["watermark"] = watermark
    if wm_col:
        sql += f' ORDER BY "{wm_col}" ASC'
    return pd.read_sql(text(sql), engine, params=params)
