MERGE INTO "Produção".dim_produto AS t
USING (
  SELECT codigo_produto,produto,categoria,subcategoria,preco_lista,custo_padrao
  FROM "Stage".lnd_dim_produto WHERE id_carga=:carga_id
) s
ON t.codigo_produto=s.codigo_produto
WHEN MATCHED THEN UPDATE SET
  produto=s.produto, categoria=s.categoria, subcategoria=s.subcategoria,
  preco_lista=s.preco_lista, custo_padrao=s.custo_padrao
WHEN NOT MATCHED THEN INSERT
  (codigo_produto,produto,categoria,subcategoria,preco_lista,custo_padrao)
VALUES
  (s.codigo_produto,s.produto,s.categoria,s.subcategoria,s.preco_lista,s.custo_padrao);
