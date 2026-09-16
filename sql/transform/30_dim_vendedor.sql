INSERT INTO "Produção".dim_vendedor(
    vendedor_id,vendedor,equipe,regiao,dt_atualizacao_origem,dt_carga,id_carga
)
SELECT vendedor_id,vendedor,equipe,regiao,dt_atualizacao,CURRENT_TIMESTAMP,:carga_id
FROM "Stage".stg_dim_vendedor
WHERE id_carga=:carga_id
ON CONFLICT (vendedor_id) DO UPDATE SET
    vendedor=EXCLUDED.vendedor,
    equipe=EXCLUDED.equipe,
    regiao=EXCLUDED.regiao,
    dt_atualizacao_origem=EXCLUDED.dt_atualizacao_origem,
    dt_carga=CURRENT_TIMESTAMP,
    id_carga=EXCLUDED.id_carga;
