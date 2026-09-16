from pathlib import Path
import logging
from dw_pipeline.config import Settings
from dw_pipeline.db import dw_engine
from dw_pipeline.logging_config import configure_logging

logger = logging.getLogger(__name__)

def main():
    settings = Settings()
    configure_logging(settings.log_level)
    engine = dw_engine(settings)
    try:
        with engine.begin() as conn:
            for path in sorted(Path("sql/bootstrap").glob("*.sql")):
                logger.info(f"Aplicando {path}")
                conn.exec_driver_sql(path.read_text(encoding="utf-8"))
        logger.info("Bootstrap concluído")
    finally:
        engine.dispose()

if __name__ == "__main__":
    main()
