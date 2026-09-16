import pandas as pd
from psycopg2 import sql
from psycopg2.extras import execute_values
from sqlalchemy.engine import Engine


def upsert_stage(engine: Engine, stage_schema: str, table: str, df: pd.DataFrame,
                 business_keys: list[str], carga_id: int, source_system: str) -> tuple[int, int]:
    if df.empty:
        return 0, 0

    work = df.copy()
    work["id_carga"] = carga_id
    work["dt_carga"] = pd.Timestamp.utcnow().tz_localize(None)
    work["sistema_origem"] = source_system
    columns = list(work.columns)
    update_cols = [c for c in columns if c not in business_keys]

    raw = engine.raw_connection()
    try:
        with raw.cursor() as cur:
            temp_name = f"tmp_{table}_{carga_id}"
            cur.execute(
                sql.SQL('CREATE TEMP TABLE {} (LIKE {}.{} INCLUDING DEFAULTS) ON COMMIT DROP').format(
                    sql.Identifier(temp_name), sql.Identifier(stage_schema), sql.Identifier(table)
                )
            )
            insert_temp = sql.SQL('INSERT INTO {} ({}) VALUES %s').format(
                sql.Identifier(temp_name), sql.SQL(',').join(map(sql.Identifier, columns))
            )
            values = [
                tuple(None if pd.isna(v) else v for v in row)
                for row in work.itertuples(index=False, name=None)
            ]
            execute_values(cur, insert_temp.as_string(cur), values, page_size=5000)

            join_cond = sql.SQL(' AND ').join(
                sql.SQL('t.{0}=s.{0}').format(sql.Identifier(k)) for k in business_keys
            )
            count_sql = sql.SQL('SELECT COUNT(*) FROM {}.{} t JOIN {} s ON {}').format(
                sql.Identifier(stage_schema), sql.Identifier(table), sql.Identifier(temp_name), join_cond
            )
            cur.execute(count_sql)
            existing = int(cur.fetchone()[0])

            upsert_sql = sql.SQL(
                'INSERT INTO {}.{} ({}) SELECT {} FROM {} '
                'ON CONFLICT ({}) DO UPDATE SET {}'
            ).format(
                sql.Identifier(stage_schema), sql.Identifier(table),
                sql.SQL(',').join(map(sql.Identifier, columns)),
                sql.SQL(',').join(map(sql.Identifier, columns)),
                sql.Identifier(temp_name),
                sql.SQL(',').join(map(sql.Identifier, business_keys)),
                sql.SQL(',').join(
                    sql.SQL('{}=EXCLUDED.{}').format(sql.Identifier(c), sql.Identifier(c))
                    for c in update_cols
                ),
            )
            cur.execute(upsert_sql)
        raw.commit()
        return len(work) - existing, existing
    except Exception:
        raw.rollback()
        raise
    finally:
        raw.close()
