import logging
import uuid
from .config import Settings, load_entities
from .db import source_engine, dw_engine
from .audit import get_watermark, set_watermark, start_load, finish_load
from .extract import extract_incremental
from .quality import validate_dataframe, record_results, run_db_quality, assert_quality
from .load_stage import upsert_stage
from .transform import execute_transform
from .powerbi import refresh_dataset

logger = logging.getLogger(__name__)


def run_entity(entity: str, spec: dict, settings: Settings, src, dw, pipeline_run_id: str) -> dict:
    source_name = f"{spec.get('source_schema', 'public')}.{spec['source_table']}"
    stage_name = f"{settings.stage_schema}.{spec['stage_table']}"
    watermark = get_watermark(dw, settings.stage_schema, entity)
    carga_id = start_load(
        dw,
        settings.stage_schema,
        pipeline_run_id=pipeline_run_id,
        entity=entity,
        environment=settings.environment,
        source_table=source_name,
        target_table=stage_name,
        watermark_before=watermark,
    )
    extra = {"pipeline_run_id": pipeline_run_id, "entity": entity, "carga_id": carga_id}
    logger.info("Carga iniciada", extra=extra)

    try:
        df = extract_incremental(src, spec, watermark)
        pre_results = validate_dataframe(entity, df, spec)
        record_results(dw, settings.stage_schema, carga_id, entity, pre_results)
        assert_quality(pre_results)

        if df.empty:
            finish_load(
                dw, settings.stage_schema, carga_id,
                status="SUCESSO", quantity=0, inserted=0, updated=0, rejected=0,
                watermark_new=watermark,
            )
            logger.info("Sem novos registros; carga concluída", extra=extra)
            return {"entity": entity, "carga_id": carga_id, "rows": 0, "inserted": 0, "updated": 0}

        inserted, updated = upsert_stage(
            dw, settings.stage_schema, spec["stage_table"], df,
            spec["business_keys"], carga_id, settings.source_system_name,
        )

        db_results = run_db_quality(dw, settings.stage_schema, carga_id, entity)
        record_results(dw, settings.stage_schema, carga_id, entity, db_results)
        assert_quality(db_results)

        execute_transform(dw, spec["transform_sql"], {"carga_id": carga_id})

        wm_col = spec.get("watermark_column")
        new_watermark = df[wm_col].max() if wm_col and wm_col in df.columns else watermark
        set_watermark(dw, settings.stage_schema, entity, wm_col or "", new_watermark)
        finish_load(
            dw, settings.stage_schema, carga_id,
            status="SUCESSO", quantity=len(df), inserted=inserted, updated=updated,
            rejected=0, watermark_new=new_watermark,
        )
        logger.info(
            f"Carga concluída: rows={len(df)} inserted={inserted} updated={updated}",
            extra=extra,
        )
        return {
            "entity": entity,
            "carga_id": carga_id,
            "rows": len(df),
            "inserted": inserted,
            "updated": updated,
        }
    except Exception as exc:
        finish_load(
            dw, settings.stage_schema, carga_id,
            status="ERRO", quantity=0, inserted=0, updated=0, rejected=0,
            watermark_new=watermark, error_message=str(exc)[:4000],
        )
        logger.exception("Carga falhou", extra=extra)
        raise


def run_pipeline(settings: Settings | None = None) -> dict:
    settings = settings or Settings()
    pipeline_run_id = str(uuid.uuid4())
    entities = load_entities(settings.entities_config)
    src = source_engine(settings)
    dw = dw_engine(settings)
    result = {"pipeline_run_id": pipeline_run_id, "entities": []}
    try:
        for entity, spec in entities.items():
            result["entities"].append(
                run_entity(entity, spec, settings, src, dw, pipeline_run_id)
            )
        result["powerbi"] = refresh_dataset(settings)
        result["status"] = "SUCESSO"
        return result
    finally:
        src.dispose()
        dw.dispose()
