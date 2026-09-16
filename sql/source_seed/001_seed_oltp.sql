-- Synthetic but business-realistic source data for portfolio/demo.
-- Idempotent: only inserts when the corresponding source table is empty.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.clientes) THEN
    INSERT INTO public.clientes
      (cliente_id,nome_cliente,segmento,porte,cidade,estado,data_cadastro,dt_criacao,dt_atualizacao)
    SELECT i,
           'Cliente ' || LPAD(i::text,4,'0'),
           (ARRAY['Enterprise','PME','Varejo'])[1 + (i % 3)],
           (ARRAY['Grande','Médio','Pequeno'])[1 + (i % 3)],
           (ARRAY['São Paulo','Rio de Janeiro','Belo Horizonte','Curitiba','Florianópolis','Salvador','Goiânia'])[1 + (i % 7)],
           (ARRAY['SP','RJ','MG','PR','SC','BA','GO'])[1 + (i % 7)],
           DATE '2024-01-01' + (i % 700),
           CURRENT_TIMESTAMP - ((500-i) || ' days')::interval,
           CURRENT_TIMESTAMP - ((i % 90) || ' hours')::interval
    FROM generate_series(1,500) i;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.produtos) THEN
    INSERT INTO public.produtos
      (produto_id,nome_produto,categoria,preco_unitario,custo_unitario,dt_criacao,dt_atualizacao)
    SELECT i,
           'Produto ' || LPAD(i::text,3,'0'),
           (ARRAY['Software','Serviços','Hardware','Cloud','Analytics'])[1 + (i % 5)],
           ROUND((120 + (i % 40) * 18.70)::numeric,2),
           ROUND((55 + (i % 35) * 9.40)::numeric,2),
           CURRENT_TIMESTAMP - ((300-i) || ' days')::interval,
           CURRENT_TIMESTAMP - ((i % 72) || ' hours')::interval
    FROM generate_series(1,120) i;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.vendedores) THEN
    INSERT INTO public.vendedores
      (vendedor_id,nome_vendedor,equipe,regiao,data_admissao,ativo,dt_criacao,dt_atualizacao)
    SELECT i,
           'Vendedor ' || LPAD(i::text,2,'0'),
           (ARRAY['Enterprise','Growth','Inside Sales','Parcerias'])[1 + (i % 4)],
           (ARRAY['Sudeste','Sul','Nordeste','Centro-Oeste'])[1 + (i % 4)],
           DATE '2021-01-01' + (i * 23),
           TRUE,
           CURRENT_TIMESTAMP - ((900-i) || ' days')::interval,
           CURRENT_TIMESTAMP - ((i % 48) || ' hours')::interval
    FROM generate_series(1,30) i;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.vendas) THEN
    INSERT INTO public.vendas
      (venda_id,cliente_id,vendedor_id,data_venda,canal_venda,desconto,dt_criacao,dt_atualizacao)
    SELECT i,
           1 + (i % 500),
           1 + (i % 30),
           DATE '2025-01-01' + (i % 623),
           (ARRAY['Direto','Online','Parceiros','Inside Sales'])[1 + (i % 4)],
           CASE WHEN i % 11 = 0 THEN 0.15 WHEN i % 5 = 0 THEN 0.08 ELSE 0.03 END,
           CURRENT_TIMESTAMP - ((623 - (i % 623)) || ' days')::interval,
           CURRENT_TIMESTAMP - ((i % 120) || ' minutes')::interval
    FROM generate_series(1,20000) i;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.itens_venda) THEN
    INSERT INTO public.itens_venda
      (item_venda_id,venda_id,produto_id,quantidade,valor_unitario,desconto,dt_criacao,dt_atualizacao)
    SELECT i,
           1 + ((i-1) % 20000),
           1 + (i % 120),
           1 + (i % 8),
           ROUND((130 + (i % 40) * 19.30)::numeric,2),
           CASE WHEN i % 13 = 0 THEN 0.10 ELSE 0 END,
           CURRENT_TIMESTAMP - (((i % 623)) || ' days')::interval,
           CURRENT_TIMESTAMP - ((i % 120) || ' minutes')::interval
    FROM generate_series(1,40000) i;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.metas) THEN
    INSERT INTO public.metas
      (meta_id,vendedor_id,ano,mes,meta_receita,dt_criacao,dt_atualizacao)
    SELECT ROW_NUMBER() OVER ()::int,
           v,
           EXTRACT(YEAR FROM m)::int,
           EXTRACT(MONTH FROM m)::int,
           ROUND((50000 + v * 1800 + EXTRACT(MONTH FROM m) * 900)::numeric,2),
           CURRENT_TIMESTAMP,
           CURRENT_TIMESTAMP
    FROM generate_series(DATE '2025-01-01', DATE '2026-12-01', INTERVAL '1 month') m
    CROSS JOIN generate_series(1,30) v;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.despesas) THEN
    INSERT INTO public.despesas
      (despesa_id,data_despesa,tipo_despesa,descricao,valor_despesa,dt_criacao,dt_atualizacao)
    SELECT i,
           DATE '2025-01-01' + (i % 623),
           (ARRAY['Pessoal','Marketing','Tecnologia','Infraestrutura','Serviços'])[1 + (i % 5)],
           'Despesa operacional ' || i,
           ROUND((800 + (i % 35) * 175.50)::numeric,2),
           CURRENT_TIMESTAMP - ((i % 623) || ' days')::interval,
           CURRENT_TIMESTAMP - ((i % 96) || ' minutes')::interval
    FROM generate_series(1,2500) i;
  END IF;
END $$;

ANALYZE public.clientes;
ANALYZE public.produtos;
ANALYZE public.vendedores;
ANALYZE public.vendas;
ANALYZE public.itens_venda;
ANALYZE public.metas;
ANALYZE public.despesas;
