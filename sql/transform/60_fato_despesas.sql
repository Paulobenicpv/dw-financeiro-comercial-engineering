INSERT INTO "Produção".dim_calendario(data_key,data,ano,mes,mes_nome,trimestre,ano_mes,inicio_mes)
SELECT DISTINCT
    TO_CHAR(data_despesa,'YYYYMMDD')::INTEGER,
    data_despesa,
    EXTRACT(YEAR FROM data_despesa)::INTEGER,
    EXTRACT(MONTH FROM data_despesa)::INTEGER,
    CASE EXTRACT(MONTH FROM data_despesa)::INTEGER
      WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março' WHEN 4 THEN 'Abril'
      WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho' WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto'
      WHEN 9 THEN 'Setembro' WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' ELSE 'Dezembro' END,
    EXTRACT(QUARTER FROM data_despesa)::INTEGER,
    TO_CHAR(data_despesa,'YYYY-MM'),
    DATE_TRUNC('month',data_despesa)::DATE
FROM "Stage".stg_fato_despesas
WHERE id_carga=:carga_id
ON CONFLICT (data_key) DO NOTHING;

INSERT INTO "Produção".fato_despesas(
    codigo_despesa,data_key,centro_custo,tipo_despesa,classificacao,valor_despesa,
    dt_atualizacao_origem,dt_carga,id_carga
)
SELECT
    despesa_id,
    TO_CHAR(data_despesa,'YYYYMMDD')::INTEGER,
    centro_custo,
    tipo_despesa,
    classificacao,
    valor_despesa,
    dt_atualizacao,
    CURRENT_TIMESTAMP,
    :carga_id
FROM "Stage".stg_fato_despesas
WHERE id_carga=:carga_id
ON CONFLICT (codigo_despesa) DO UPDATE SET
    data_key=EXCLUDED.data_key,
    centro_custo=EXCLUDED.centro_custo,
    tipo_despesa=EXCLUDED.tipo_despesa,
    classificacao=EXCLUDED.classificacao,
    valor_despesa=EXCLUDED.valor_despesa,
    dt_atualizacao_origem=EXCLUDED.dt_atualizacao_origem,
    dt_carga=CURRENT_TIMESTAMP,
    id_carga=EXCLUDED.id_carga;
