SELECT 'vw_etl_clientes' AS objeto, COUNT(*) AS linhas FROM public.vw_etl_clientes
UNION ALL SELECT 'vw_etl_produtos', COUNT(*) FROM public.vw_etl_produtos
UNION ALL SELECT 'vw_etl_vendedores', COUNT(*) FROM public.vw_etl_vendedores
UNION ALL SELECT 'vw_etl_vendas', COUNT(*) FROM public.vw_etl_vendas
UNION ALL SELECT 'vw_etl_metas', COUNT(*) FROM public.vw_etl_metas
UNION ALL SELECT 'vw_etl_despesas', COUNT(*) FROM public.vw_etl_despesas;
