import uuid

from prefect import flow, task, get_run_logger
from prefect.schedules import Cron

from dw_pipeline.config import Settings, load_entities
from dw_pipeline.db import source_engine, dw_engine
from dw_pipeline.pipeline import run_entity
from dw_pipeline.powerbi import refresh_dataset
from dw_pipeline.logging_config import configure_logging


# ============================================================
# TASK - PROCESSAMENTO DE ENTIDADE
# ============================================================

@task(
    retries=3,
    retry_delay_seconds=60,
    timeout_seconds=1800
)
def process_entity(
    entity: str,
    spec: dict,
    pipeline_run_id: str
):
    """
    Processa uma entidade do pipeline.

    Fluxo:
    Source Contract
        -> Extração incremental
        -> Stage
        -> Data Quality
        -> Produção
        -> Watermark
        -> Auditoria
    """

    settings = Settings()

    src = source_engine(settings)
    dw = dw_engine(settings)

    try:
        return run_entity(
            entity=entity,
            spec=spec,
            settings=settings,
            src=src,
            dw=dw,
            pipeline_run_id=pipeline_run_id
        )

    finally:
        src.dispose()
        dw.dispose()


# ============================================================
# TASK - REFRESH POWER BI
# ============================================================

@task(
    retries=2,
    retry_delay_seconds=60
)
def refresh_powerbi_task():
    """
    Executa refresh do dataset Power BI.

    Caso POWERBI_REFRESH_ENABLED=false,
    o processo retorna SKIPPED.
    """

    settings = Settings()

    return refresh_dataset(settings)


# ============================================================
# FLOW PRINCIPAL
# ============================================================

@flow(
    name="dw-financeiro-comercial",
    log_prints=True
)
def dw_financeiro_comercial_flow():
    """
    Pipeline corporativo de Engenharia de Dados.

    Arquitetura:

    OLTP PostgreSQL
        ↓
    Source Contract
        ↓
    ETL Python Incremental
        ↓
    Stage / Landing
        ↓
    Data Quality
        ↓
    Data Warehouse
        ↓
    Views Analíticas
        ↓
    Power BI
    """

    settings = Settings()

    configure_logging(settings.log_level)

    logger = get_run_logger()

    pipeline_run_id = str(uuid.uuid4())

    logger.info(
        f"Iniciando pipeline_run_id={pipeline_run_id}"
    )

    entities = load_entities()

    results = []

    # --------------------------------------------------------
    # PROCESSAMENTO DAS ENTIDADES
    # --------------------------------------------------------

    for entity, spec in entities.items():

        logger.info(
            f"Iniciando processamento da entidade: {entity}"
        )

        result = process_entity(
            entity,
            spec,
            pipeline_run_id
        )

        results.append(result)

    # --------------------------------------------------------
    # POWER BI
    # --------------------------------------------------------

    logger.info(
        "Iniciando etapa de atualização do Power BI"
    )

    powerbi_result = refresh_powerbi_task()

    logger.info(
        "Pipeline concluído com sucesso"
    )

    return {
        "pipeline_run_id": pipeline_run_id,
        "entities": results,
        "powerbi": powerbi_result,
        "status": "SUCESSO"
    }


# ============================================================
# DEPLOYMENT / AGENDAMENTO
# ============================================================

if __name__ == "__main__":

    dw_financeiro_comercial_flow.serve(

        name="dw-financeiro-comercial-producao",

        schedule=Cron(
            "0 6 * * *",
            timezone="America/Sao_Paulo"
        ),

        tags=[
            "engenharia-de-dados",
            "postgresql",
            "etl",
            "data-quality",
            "dw-financeiro",
            "power-bi",
            "producao"
        ],

        description=(
            "Pipeline incremental corporativo para ingestão de dados "
            "do OLTP Financeiro Comercial, processamento em Stage, "
            "validação de Data Quality, carga no Data Warehouse "
            "e atualização do Power BI."
        ),

        pause_on_shutdown=False
    )