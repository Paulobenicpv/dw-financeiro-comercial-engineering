from sqlalchemy import text
from dw_pipeline.config import Settings
from dw_pipeline.db import source_engine, dw_engine


def check(name, engine):
    try:
        with engine.connect() as conn:
            db = conn.execute(text("SELECT current_database()" )).scalar_one()
            version = conn.execute(text("SHOW server_version" )).scalar_one()
        print(f"[OK] {name}: database={db} PostgreSQL={version}")
    finally:
        engine.dispose()


if __name__ == "__main__":
    settings = Settings()
    check("SOURCE", source_engine(settings))
    check("DW", dw_engine(settings))
