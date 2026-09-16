from sqlalchemy import text
from sqlalchemy.engine import Engine


def get_watermark(engine: Engine, stage_schema: str, entity: str):
    query = text(f'SELECT valor_watermark FROM "{stage_schema}".etl_watermark WHERE entidade=:entity')
    with engine.connect() as conn:
        row = conn.execute(query, {"entity": entity}).first()
        return row[0] if row else None


def set_watermark(engine: Engine, stage_schema: str, entity: str, column: str, value):
    if value is None:
        return
    query = text(f'''
        INSERT INTO "{stage_schema}".etl_watermark(entidade,coluna_watermark,valor_watermark,updated_at)
        VALUES (:entity,:column,:value,CURRENT_TIMESTAMP)
        ON CONFLICT (entidade) DO UPDATE SET
            coluna_watermark=EXCLUDED.coluna_watermark,
            valor_watermark=EXCLUDED.valor_watermark,
            updated_at=CURRENT_TIMESTAMP
    ''')
    with engine.begin() as conn:
        conn.execute(query, {"entity": entity, "column": column, "value": value})


def start_load(engine: Engine, stage_schema: str, *, pipeline_run_id: str, entity: str,
               environment: str, source_table: str, target_table: str, watermark_before):
    query = text(f'''
        INSERT INTO "{stage_schema}".controle_carga(
            pipeline_run_id,entidade,ambiente,tabela_origem,tabela_destino,
            status_carga,data_inicio,watermark_anterior
        ) VALUES (
            CAST(:pipeline_run_id AS uuid),:entity,:environment,:source_table,:target_table,
            'EM_EXECUCAO',CURRENT_TIMESTAMP,:watermark_before
        ) RETURNING carga_id
    ''')
    with engine.begin() as conn:
        return conn.execute(query, {
            "pipeline_run_id": pipeline_run_id,
            "entity": entity,
            "environment": environment,
            "source_table": source_table,
            "target_table": target_table,
            "watermark_before": watermark_before,
        }).scalar_one()


def finish_load(engine: Engine, stage_schema: str, carga_id: int, *, status: str,
                quantity: int, inserted: int, updated: int, rejected: int,
                watermark_new=None, error_message=None):
    query = text(f'''
        UPDATE "{stage_schema}".controle_carga
           SET status_carga=:status,
               quantidade_linhas=:quantity,
               linhas_inseridas=:inserted,
               linhas_atualizadas=:updated,
               linhas_rejeitadas=:rejected,
               watermark_novo=:watermark_new,
               mensagem_erro=:error_message,
               data_fim=CURRENT_TIMESTAMP,
               duracao_segundos=EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP-data_inicio))
         WHERE carga_id=:carga_id
    ''')
    params = {
        "status": status, "quantity": quantity, "inserted": inserted,
        "updated": updated, "rejected": rejected,
        "watermark_new": watermark_new, "error_message": error_message,
        "carga_id": carga_id,
    }
    with engine.begin() as conn:
        conn.execute(query, params)
