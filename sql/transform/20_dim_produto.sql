INSERT INTO "Produção".dim_produto(
    produto_id,produto,categoria,subcategoria,custo_unitario,dt_atualizacao_origem,dt_carga,id_carga
)
SELECT produto_id,produto,categoria,subcategoria,custo_unitario,dt_atualizacao,CURRENT_TIMESTAMP,:carga_id
FROM "Stage".stg_dim_produto
WHERE id_carga=:carga_id
ON CONFLICT (produto_id) DO UPDATE SET
    produto=EXCLUDED.produto,
    categoria=EXCLUDED.categoria,
    subcategoria=EXCLUDED.subcategoria,
    custo_unitario=EXCLUDED.custo_unitario,
    dt_atualizacao_origem=EXCLUDED.dt_atualizacao_origem,
    dt_carga=CURRENT_TIMESTAMP,
    id_carga=EXCLUDED.id_carga;
