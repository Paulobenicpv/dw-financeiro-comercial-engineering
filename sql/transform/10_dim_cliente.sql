INSERT INTO "Produção".dim_cliente(
    cliente_id,nome_cliente,segmento,porte,regiao,uf,dt_atualizacao_origem,dt_carga,id_carga
)
SELECT cliente_id,nome_cliente,segmento,porte,regiao,uf,dt_atualizacao,CURRENT_TIMESTAMP,:carga_id
FROM "Stage".stg_dim_cliente
WHERE id_carga=:carga_id
ON CONFLICT (cliente_id) DO UPDATE SET
    nome_cliente=EXCLUDED.nome_cliente,
    segmento=EXCLUDED.segmento,
    porte=EXCLUDED.porte,
    regiao=EXCLUDED.regiao,
    uf=EXCLUDED.uf,
    dt_atualizacao_origem=EXCLUDED.dt_atualizacao_origem,
    dt_carga=CURRENT_TIMESTAMP,
    id_carga=EXCLUDED.id_carga;
