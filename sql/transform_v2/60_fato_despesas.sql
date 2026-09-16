MERGE INTO "Produção".fato_despesas AS t
USING (
  SELECT codigo_despesa, TO_CHAR(data_despesa,'YYYYMMDD')::integer AS data_key,
         centro_custo,tipo_despesa,classificacao,valor_despesa
  FROM "Stage".lnd_fato_despesas WHERE id_carga=:carga_id
) s
ON t.codigo_despesa=s.codigo_despesa
WHEN MATCHED THEN UPDATE SET
  data_key=s.data_key, centro_custo=s.centro_custo, tipo_despesa=s.tipo_despesa,
  classificacao=s.classificacao, valor_despesa=s.valor_despesa
WHEN NOT MATCHED THEN INSERT
  (codigo_despesa,data_key,centro_custo,tipo_despesa,classificacao,valor_despesa)
VALUES
  (s.codigo_despesa,s.data_key,s.centro_custo,s.tipo_despesa,s.classificacao,s.valor_despesa);
