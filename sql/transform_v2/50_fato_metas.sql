MERGE INTO "Produção".fato_metas AS t
USING (
  SELECT s.codigo_meta, TO_CHAR(s.data_meta,'YYYYMMDD')::integer AS data_key,
         v.vendedor_key, s.meta_receita, s.meta_margem, s.meta_novos_clientes
  FROM "Stage".lnd_fato_metas s
  JOIN "Produção".dim_vendedor v ON v.codigo_vendedor=s.codigo_vendedor
  WHERE s.id_carga=:carga_id
) s
ON t.codigo_meta=s.codigo_meta
WHEN MATCHED THEN UPDATE SET
  data_key=s.data_key, vendedor_key=s.vendedor_key, meta_receita=s.meta_receita,
  meta_margem=s.meta_margem, meta_novos_clientes=s.meta_novos_clientes
WHEN NOT MATCHED THEN INSERT
  (codigo_meta,data_key,vendedor_key,meta_receita,meta_margem,meta_novos_clientes)
VALUES
  (s.codigo_meta,s.data_key,s.vendedor_key,s.meta_receita,s.meta_margem,s.meta_novos_clientes);
