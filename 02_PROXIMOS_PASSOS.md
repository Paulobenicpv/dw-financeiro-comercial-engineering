# Próximos passos — versão adaptada ao OLTP real

Esta versão usa a origem normalizada `oltp_financeiro_comercial` com as tabelas `clientes`, `produtos`, `vendedores`, `vendas`, `itens_venda`, `metas` e `despesas`.

## Ordem segura de execução

1. **No banco `oltp_financeiro_comercial`** execute:
   - `sql/source_seed/001_seed_oltp.sql`
   - `sql/source_contract/001_contract_views.sql`
2. Valide as views:
   - `SELECT COUNT(*) FROM public.vw_etl_clientes;`
   - `SELECT COUNT(*) FROM public.vw_etl_produtos;`
   - `SELECT COUNT(*) FROM public.vw_etl_vendedores;`
   - `SELECT COUNT(*) FROM public.vw_etl_vendas;`
   - `SELECT COUNT(*) FROM public.vw_etl_metas;`
   - `SELECT COUNT(*) FROM public.vw_etl_despesas;`
3. **No banco `dw_financeiro_comercial`** execute apenas:
   - `sql/bootstrap/001_schemas_control.sql`
   - `sql/bootstrap/002_stage_tables.sql`
4. Configure `.env` com origem `oltp_financeiro_comercial` e destino `dw_financeiro_comercial`.
5. Rode `python scripts/check_connections.py`.
6. Rode `python scripts/run_pipeline.py`.
7. Valide `Stage.controle_carga`, `Stage.dq_resultado` e as tabelas de `Produção`.
8. Atualize o Power BI.

## Observação importante

Os scripts `sql/transform_v2/*.sql` foram escritos para o modelo de Produção que já existe no seu DW (`codigo_cliente`, `codigo_produto`, `codigo_vendedor`, `codigo_venda`, etc.). Eles não recriam nem apagam suas tabelas de Produção.
