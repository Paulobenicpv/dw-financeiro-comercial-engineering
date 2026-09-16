INSERT INTO "Produção".dim_calendario(data_key,data,ano,mes,mes_nome,trimestre,ano_mes,inicio_mes)
SELECT DISTINCT
    TO_CHAR(data_venda,'YYYYMMDD')::INTEGER,
    data_venda,
    EXTRACT(YEAR FROM data_venda)::INTEGER,
    EXTRACT(MONTH FROM data_venda)::INTEGER,
    CASE EXTRACT(MONTH FROM data_venda)::INTEGER
      WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março' WHEN 4 THEN 'Abril'
      WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho' WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto'
      WHEN 9 THEN 'Setembro' WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' ELSE 'Dezembro' END,
    EXTRACT(QUARTER FROM data_venda)::INTEGER,
    TO_CHAR(data_venda,'YYYY-MM'),
    DATE_TRUNC('month',data_venda)::DATE
FROM "Stage".stg_fato_vendas
WHERE id_carga=:carga_id
ON CONFLICT (data_key) DO NOTHING;

INSERT INTO "Produção".fato_vendas(
    codigo_venda,data_key,cliente_key,produto_key,vendedor_key,canal,quantidade,preco_unitario,
    receita_bruta,percentual_desconto,valor_desconto,receita_liquida,custo_total,lucro_bruto,
    dt_atualizacao_origem,dt_carga,id_carga
)
SELECT
    s.venda_id,
    TO_CHAR(s.data_venda,'YYYYMMDD')::INTEGER,
    c.cliente_key,
    p.produto_key,
    v.vendedor_key,
    s.canal,
    s.quantidade,
    s.preco_unitario,
    ROUND((s.quantidade*s.preco_unitario)::numeric,2),
    COALESCE(s.percentual_desconto,0),
    ROUND((s.quantidade*s.preco_unitario*COALESCE(s.percentual_desconto,0))::numeric,2),
    ROUND((s.quantidade*s.preco_unitario*(1-COALESCE(s.percentual_desconto,0)))::numeric,2),
    ROUND((s.quantidade*COALESCE(p.custo_unitario,0))::numeric,2),
    ROUND(((s.quantidade*s.preco_unitario*(1-COALESCE(s.percentual_desconto,0))) - (s.quantidade*COALESCE(p.custo_unitario,0)))::numeric,2),
    s.dt_atualizacao,
    CURRENT_TIMESTAMP,
    :carga_id
FROM "Stage".stg_fato_vendas s
JOIN "Produção".dim_cliente c ON c.cliente_id=s.cliente_id
JOIN "Produção".dim_produto p ON p.produto_id=s.produto_id
JOIN "Produção".dim_vendedor v ON v.vendedor_id=s.vendedor_id
WHERE s.id_carga=:carga_id
ON CONFLICT (codigo_venda) DO UPDATE SET
    data_key=EXCLUDED.data_key,
    cliente_key=EXCLUDED.cliente_key,
    produto_key=EXCLUDED.produto_key,
    vendedor_key=EXCLUDED.vendedor_key,
    canal=EXCLUDED.canal,
    quantidade=EXCLUDED.quantidade,
    preco_unitario=EXCLUDED.preco_unitario,
    receita_bruta=EXCLUDED.receita_bruta,
    percentual_desconto=EXCLUDED.percentual_desconto,
    valor_desconto=EXCLUDED.valor_desconto,
    receita_liquida=EXCLUDED.receita_liquida,
    custo_total=EXCLUDED.custo_total,
    lucro_bruto=EXCLUDED.lucro_bruto,
    dt_atualizacao_origem=EXCLUDED.dt_atualizacao_origem,
    dt_carga=CURRENT_TIMESTAMP,
    id_carga=EXCLUDED.id_carga;
