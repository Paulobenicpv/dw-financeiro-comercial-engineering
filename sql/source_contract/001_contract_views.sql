-- Source contract views. Base OLTP stays normalized; ETL reads a stable contract.
-- Assumes the columns confirmed in the user's oltp_financeiro_comercial schema.

CREATE OR REPLACE VIEW public.vw_etl_clientes AS
SELECT
    c.cliente_id::bigint AS source_cliente_id,
    ('OLTP-CLI-' || c.cliente_id)::varchar(60) AS codigo_cliente,
    c.nome_cliente::varchar(200) AS nome_cliente,
    c.segmento::varchar(100) AS segmento,
    c.porte::varchar(50) AS porte,
    CASE UPPER(COALESCE(c.estado,''))
      WHEN 'SP' THEN 'Sudeste' WHEN 'RJ' THEN 'Sudeste' WHEN 'MG' THEN 'Sudeste' WHEN 'ES' THEN 'Sudeste'
      WHEN 'PR' THEN 'Sul' WHEN 'SC' THEN 'Sul' WHEN 'RS' THEN 'Sul'
      WHEN 'GO' THEN 'Centro-Oeste' WHEN 'MT' THEN 'Centro-Oeste' WHEN 'MS' THEN 'Centro-Oeste' WHEN 'DF' THEN 'Centro-Oeste'
      WHEN 'BA' THEN 'Nordeste' WHEN 'PE' THEN 'Nordeste' WHEN 'CE' THEN 'Nordeste' WHEN 'RN' THEN 'Nordeste'
      ELSE 'Outros'
    END::varchar(100) AS regiao,
    c.estado::varchar(10) AS uf,
    c.cidade::varchar(120) AS cidade,
    'Ativo'::varchar(50) AS status_cliente,
    COALESCE(c.dt_atualizacao, c.dt_criacao, CURRENT_TIMESTAMP)::timestamp AS dt_atualizacao
FROM public.clientes c;

CREATE OR REPLACE VIEW public.vw_etl_produtos AS
SELECT
    p.produto_id::bigint AS source_produto_id,
    ('OLTP-PRD-' || p.produto_id)::varchar(60) AS codigo_produto,
    p.nome_produto::varchar(200) AS produto,
    p.categoria::varchar(100) AS categoria,
    'Não informado'::varchar(100) AS subcategoria,
    COALESCE(p.preco_unitario,0)::numeric(18,2) AS preco_lista,
    COALESCE(p.custo_unitario,0)::numeric(18,2) AS custo_padrao,
    COALESCE(p.dt_atualizacao, p.dt_criacao, CURRENT_TIMESTAMP)::timestamp AS dt_atualizacao
FROM public.produtos p;

CREATE OR REPLACE VIEW public.vw_etl_vendedores AS
SELECT
    v.vendedor_id::bigint AS source_vendedor_id,
    ('OLTP-VND-' || v.vendedor_id)::varchar(60) AS codigo_vendedor,
    v.nome_vendedor::varchar(200) AS vendedor,
    v.regiao::varchar(100) AS regiao,
    v.equipe::varchar(100) AS equipe,
    'Executivo Comercial'::varchar(100) AS cargo,
    v.data_admissao::date AS data_admissao,
    COALESCE(v.dt_atualizacao, v.dt_criacao, CURRENT_TIMESTAMP)::timestamp AS dt_atualizacao
FROM public.vendedores v
WHERE COALESCE(v.ativo, TRUE) = TRUE;

CREATE OR REPLACE VIEW public.vw_etl_vendas AS
SELECT
    i.item_venda_id::bigint AS source_item_id,
    ('OLTP-IT-' || i.item_venda_id)::varchar(80) AS codigo_venda,
    v.data_venda::date AS data_venda,
    ('OLTP-CLI-' || v.cliente_id)::varchar(60) AS codigo_cliente,
    ('OLTP-PRD-' || i.produto_id)::varchar(60) AS codigo_produto,
    ('OLTP-VND-' || v.vendedor_id)::varchar(60) AS codigo_vendedor,
    COALESCE(v.canal_venda,'Não informado')::varchar(100) AS canal,
    i.quantidade::integer AS quantidade,
    i.valor_unitario::numeric(18,2) AS preco_unitario,
    CASE
      WHEN COALESCE(i.desconto, v.desconto, 0) > 1 THEN COALESCE(i.desconto, v.desconto, 0) / 100.0
      ELSE COALESCE(i.desconto, v.desconto, 0)
    END::numeric(10,6) AS percentual_desconto,
    'Não informado'::varchar(100) AS forma_pagamento,
    30::integer AS prazo_recebimento_dias,
    'Concluída'::varchar(50) AS status_venda,
    COALESCE(c.porte, c.segmento, 'Não informado')::varchar(100) AS tipo_cliente,
    GREATEST(
      COALESCE(i.dt_atualizacao, i.dt_criacao, TIMESTAMP '1900-01-01'),
      COALESCE(v.dt_atualizacao, v.dt_criacao, TIMESTAMP '1900-01-01'),
      COALESCE(p.dt_atualizacao, p.dt_criacao, TIMESTAMP '1900-01-01'),
      COALESCE(c.dt_atualizacao, c.dt_criacao, TIMESTAMP '1900-01-01')
    )::timestamp AS dt_atualizacao
FROM public.itens_venda i
JOIN public.vendas v ON v.venda_id = i.venda_id
JOIN public.produtos p ON p.produto_id = i.produto_id
JOIN public.clientes c ON c.cliente_id = v.cliente_id;

CREATE OR REPLACE VIEW public.vw_etl_metas AS
SELECT
    m.meta_id::bigint AS source_meta_id,
    ('OLTP-META-' || m.meta_id)::varchar(80) AS codigo_meta,
    make_date(m.ano, m.mes, 1)::date AS data_meta,
    ('OLTP-VND-' || m.vendedor_id)::varchar(60) AS codigo_vendedor,
    m.meta_receita::numeric(18,2) AS meta_receita,
    0.35::numeric(12,6) AS meta_margem,
    5::integer AS meta_novos_clientes,
    COALESCE(m.dt_atualizacao, m.dt_criacao, CURRENT_TIMESTAMP)::timestamp AS dt_atualizacao
FROM public.metas m;

CREATE OR REPLACE VIEW public.vw_etl_despesas AS
SELECT
    d.despesa_id::bigint AS source_despesa_id,
    ('OLTP-DESP-' || d.despesa_id)::varchar(80) AS codigo_despesa,
    d.data_despesa::date AS data_despesa,
    'Corporativo'::varchar(100) AS centro_custo,
    d.tipo_despesa::varchar(100) AS tipo_despesa,
    'Operacional'::varchar(100) AS classificacao,
    d.valor_despesa::numeric(18,2) AS valor_despesa,
    COALESCE(d.dt_atualizacao, d.dt_criacao, CURRENT_TIMESTAMP)::timestamp AS dt_atualizacao
FROM public.despesas d;
