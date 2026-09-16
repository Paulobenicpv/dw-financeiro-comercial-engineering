INSERT INTO "Produção".dim_calendario(data_key,data,ano,mes,mes_nome,trimestre,ano_mes,inicio_mes)
SELECT DISTINCT
    TO_CHAR(data_meta,'YYYYMMDD')::INTEGER,
    data_meta,
    EXTRACT(YEAR FROM data_meta)::INTEGER,
    EXTRACT(MONTH FROM data_meta)::INTEGER,
    CASE EXTRACT(MONTH FROM data_meta)::INTEGER
      WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março' WHEN 4 THEN 'Abril'
      WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho' WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto'
      WHEN 9 THEN 'Setembro' WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' ELSE 'Dezembro' END,
    EXTRACT(QUARTER FROM data_meta)::INTEGER,
    TO_CHAR(data_meta,'YYYY-MM'),
    DATE_TRUNC('month',data_meta)::DATE
FROM "Stage".stg_fato_metas
WHERE id_carga=:carga_id
ON CONFLICT (data_key) DO NOTHING;

INSERT INTO "Produção".fato_metas(
    codigo_meta,data_key,vendedor_key,meta_receita,dt_atualizacao_origem,dt_carga,id_carga
)
SELECT
    s.meta_id,
    TO_CHAR(s.data_meta,'YYYYMMDD')::INTEGER,
    v.vendedor_key,
    s.meta_receita,
    s.dt_atualizacao,
    CURRENT_TIMESTAMP,
    :carga_id
FROM "Stage".stg_fato_metas s
JOIN "Produção".dim_vendedor v ON v.vendedor_id=s.vendedor_id
WHERE s.id_carga=:carga_id
ON CONFLICT (codigo_meta) DO UPDATE SET
    data_key=EXCLUDED.data_key,
    vendedor_key=EXCLUDED.vendedor_key,
    meta_receita=EXCLUDED.meta_receita,
    dt_atualizacao_origem=EXCLUDED.dt_atualizacao_origem,
    dt_carga=CURRENT_TIMESTAMP,
    id_carga=EXCLUDED.id_carga;
