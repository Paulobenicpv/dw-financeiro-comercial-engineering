MERGE INTO "Produção".dim_vendedor AS t
USING (
  SELECT codigo_vendedor,vendedor,regiao,equipe,cargo,data_admissao
  FROM "Stage".lnd_dim_vendedor WHERE id_carga=:carga_id
) s
ON t.codigo_vendedor=s.codigo_vendedor
WHEN MATCHED THEN UPDATE SET
  vendedor=s.vendedor, regiao=s.regiao, equipe=s.equipe, cargo=s.cargo, data_admissao=s.data_admissao
WHEN NOT MATCHED THEN INSERT
  (codigo_vendedor,vendedor,regiao,equipe,cargo,data_admissao)
VALUES
  (s.codigo_vendedor,s.vendedor,s.regiao,s.equipe,s.cargo,s.data_admissao);
