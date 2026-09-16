import json
from dw_pipeline.config import Settings
from dw_pipeline.logging_config import configure_logging
from dw_pipeline.pipeline import run_pipeline

if __name__ == "__main__":
    settings = Settings()
    configure_logging(settings.log_level)
    result = run_pipeline(settings)
    print(json.dumps(result, ensure_ascii=False, default=str, indent=2))
