import pandas as pd
from sqlalchemy import text
from sqlalchemy.engine import Engine

class DataQualityError(RuntimeError):
    pass


def validate_dataframe(entity: str, df: pd.DataFrame, spec: dict) -> list[dict]:
    results: list[dict] = []
    for col in spec.get("required", []):
        bad = int(df[col].isna().sum()) if col in df.columns else len(df)
        results.append({"rule": f"required:{col}", "severity": "ERROR", "count": bad})
    for col in spec.get("positive", []):
        bad = int((pd.to_numeric(df[col], errors="coerce") <= 0).sum()) if col in df.columns else len(df)
        results.append({"rule": f"positive:{col}", "severity": "ERROR", "count": bad})
    for col in spec.get("nonnegative", []):
        bad = int((pd.to_numeric(df[col], errors="coerce") < 0).sum()) if col in df.columns else len(df)
        results.append({"rule": f"nonnegative:{col}", "severity": "ERROR", "count": bad})
    keys = spec.get("business_keys", [])
    if keys and not df.empty:
        bad = int(df.duplicated(subset=keys, keep=False).sum())
        results.append({"rule": f"duplicate_business_key:{','.join(keys)}", "severity": "ERROR", "count": bad})
    return results


def record_results(engine: Engine, stage_schema: str, carga_id: int, entity: str, results: list[dict]):
    if not results:
        return
    query = text(f'''
        INSERT INTO "{stage_schema}".dq_resultado(
            carga_id,entidade,regra,severidade,quantidade,status,executado_em
        ) VALUES (
            :carga_id,:entity,:rule,:severity,:count,
            CASE WHEN :count=0 THEN 'OK' ELSE 'ALERTA' END,CURRENT_TIMESTAMP
        )
    ''')
    with engine.begin() as conn:
        for result in results:
            conn.execute(query, {"carga_id": carga_id, "entity": entity, **result})


def run_db_quality(engine: Engine, stage_schema: str, carga_id: int, entity: str) -> list[dict]:
    checks: list[tuple[str, str]] = []
    if entity == "vendas":
        checks = [
            ("dim_cliente_existente", f'''SELECT COUNT(*) FROM "{stage_schema}".lnd_fato_vendas s LEFT JOIN "Produção".dim_cliente d ON d.codigo_cliente=s.codigo_cliente WHERE s.id_carga=:carga_id AND d.cliente_key IS NULL'''),
            ("dim_produto_existente", f'''SELECT COUNT(*) FROM "{stage_schema}".lnd_fato_vendas s LEFT JOIN "Produção".dim_produto d ON d.codigo_produto=s.codigo_produto WHERE s.id_carga=:carga_id AND d.produto_key IS NULL'''),
            ("dim_vendedor_existente", f'''SELECT COUNT(*) FROM "{stage_schema}".lnd_fato_vendas s LEFT JOIN "Produção".dim_vendedor d ON d.codigo_vendedor=s.codigo_vendedor WHERE s.id_carga=:carga_id AND d.vendedor_key IS NULL'''),
            ("desconto_maior_100", f'''SELECT COUNT(*) FROM "{stage_schema}".lnd_fato_vendas WHERE id_carga=:carga_id AND percentual_desconto > 1'''),
        ]
    elif entity == "metas":
        checks = [
            ("dim_vendedor_existente", f'''SELECT COUNT(*) FROM "{stage_schema}".lnd_fato_metas s LEFT JOIN "Produção".dim_vendedor d ON d.codigo_vendedor=s.codigo_vendedor WHERE s.id_carga=:carga_id AND d.vendedor_key IS NULL''')
        ]

    results = []
    with engine.connect() as conn:
        for name, sql_text in checks:
            count = int(conn.execute(text(sql_text), {"carga_id": carga_id}).scalar_one())
            results.append({"rule": name, "severity": "ERROR", "count": count})
    return results


def assert_quality(results: list[dict]):
    failures = [r for r in results if r["severity"] == "ERROR" and r["count"] > 0]
    if failures:
        detail = "; ".join(f"{r['rule']}={r['count']}" for r in failures)
        raise DataQualityError(f"Data Quality reprovado: {detail}")
