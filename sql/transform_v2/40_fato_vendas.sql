MERGE INTO "Produção".fato_vendas AS t
USING (
  SELECT
    s.codigo_venda,
    TO_CHAR(s.data_venda,'YYYYMMDD')::integer AS data_key,
    c.cliente_key,
    p.produto_key,
    v.vendedor_key,
    s.canal,
    s.quantidade,
    s.preco_unitario,
    ROUND((s.quantidade*s.preco_unitario)::numeric,2) AS receita_bruta,
    COALESCE(s.percentual_desconto,0) AS percentual_desconto,
    ROUND((s.quantidade*s.preco_unitario*COALESCE(s.percentual_desconto,0))::numeric,2) AS valor_desconto,
    ROUND((s.quantidade*s.preco_unitario*(1-COALESCE(s.percentual_desconto,0)))::numeric,2) AS receita_liquida,
    ROUND((s.quantidade*COALESCE(p.custo_padrao,0))::numeric,2) AS custo_total,
    ROUND(((s.quantidade*s.preco_unitario*(1-COALESCE(s.percentual_desconto,0))) - (s.quantidade*COALESCE(p.custo_padrao,0)))::numeric,2) AS lucro_bruto,
    CASE WHEN (s.quantidade*s.preco_unitario*(1-COALESCE(s.percentual_desconto,0))) = 0 THEN 0
         ELSE ROUND((((s.quantidade*s.preco_unitario*(1-COALESCE(s.percentual_desconto,0))) - (s.quantidade*COALESCE(p.custo_padrao,0))) /
              (s.quantidade*s.preco_unitario*(1-COALESCE(s.percentual_desconto,0))))::numeric,6) END AS margem_bruta,
    s.forma_pagamento,
    s.prazo_recebimento_dias,
    s.status_venda,
    s.tipo_cliente
  FROM "Stage".lnd_fato_vendas s
  JOIN "Produção".dim_cliente c ON c.codigo_cliente=s.codigo_cliente
  JOIN "Produção".dim_produto p ON p.codigo_produto=s.codigo_produto
  JOIN "Produção".dim_vendedor v ON v.codigo_vendedor=s.codigo_vendedor
  WHERE s.id_carga=:carga_id
) s
ON t.codigo_venda=s.codigo_venda
WHEN MATCHED THEN UPDATE SET
  data_key=s.data_key, cliente_key=s.cliente_key, produto_key=s.produto_key, vendedor_key=s.vendedor_key,
  canal=s.canal, quantidade=s.quantidade, preco_unitario=s.preco_unitario, receita_bruta=s.receita_bruta,
  percentual_desconto=s.percentual_desconto, valor_desconto=s.valor_desconto, receita_liquida=s.receita_liquida,
  custo_total=s.custo_total, lucro_bruto=s.lucro_bruto, margem_bruta=s.margem_bruta,
  forma_pagamento=s.forma_pagamento, prazo_recebimento_dias=s.prazo_recebimento_dias,
  status_venda=s.status_venda, tipo_cliente=s.tipo_cliente
WHEN NOT MATCHED THEN INSERT
  (codigo_venda,data_key,cliente_key,produto_key,vendedor_key,canal,quantidade,preco_unitario,
   receita_bruta,percentual_desconto,valor_desconto,receita_liquida,custo_total,lucro_bruto,margem_bruta,
   forma_pagamento,prazo_recebimento_dias,status_venda,tipo_cliente)
VALUES
  (s.codigo_venda,s.data_key,s.cliente_key,s.produto_key,s.vendedor_key,s.canal,s.quantidade,s.preco_unitario,
   s.receita_bruta,s.percentual_desconto,s.valor_desconto,s.receita_liquida,s.custo_total,s.lucro_bruto,s.margem_bruta,
   s.forma_pagamento,s.prazo_recebimento_dias,s.status_venda,s.tipo_cliente);
