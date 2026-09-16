MERGE INTO "Produção".dim_cliente AS t
USING (
  SELECT codigo_cliente,nome_cliente,segmento,porte,regiao,uf,cidade,status_cliente
  FROM "Stage".lnd_dim_cliente WHERE id_carga=:carga_id
) s
ON t.codigo_cliente=s.codigo_cliente
WHEN MATCHED THEN UPDATE SET
  nome_cliente=s.nome_cliente, segmento=s.segmento, porte=s.porte, regiao=s.regiao,
  uf=s.uf, cidade=s.cidade, status_cliente=s.status_cliente
WHEN NOT MATCHED THEN INSERT
  (codigo_cliente,nome_cliente,segmento,porte,regiao,uf,cidade,status_cliente)
VALUES
  (s.codigo_cliente,s.nome_cliente,s.segmento,s.porte,s.regiao,s.uf,s.cidade,s.status_cliente);
