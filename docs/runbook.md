# Runbook operacional

## Execução

```bash
PYTHONPATH=src python scripts/run_pipeline.py
```

## Últimas cargas

```sql
SELECT *
FROM "Stage".vw_monitoramento_cargas
ORDER BY carga_id DESC
LIMIT 20;
```

## Data Quality

```sql
SELECT * FROM "Stage".dq_resultado ORDER BY dq_id DESC LIMIT 100;
SELECT * FROM "Produção".vw_qualidade_dados;
```

## Falha de Data Quality

1. Não altere o watermark.
2. Corrija o dado na origem ou a regra incorreta.
3. Rerode o pipeline.
4. O upsert evita duplicação.

## Falha depois do Stage e antes de Produção

O watermark não terá avançado. O rerun reprocessa os mesmos registros.

## Backfill controlado

```sql
UPDATE "Stage".etl_watermark
SET valor_watermark = TIMESTAMP '2026-01-01 00:00:00'
WHERE entidade = 'vendas';
```

Use backfill apenas de forma controlada e documentada.
