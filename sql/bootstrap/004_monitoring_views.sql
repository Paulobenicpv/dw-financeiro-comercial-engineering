CREATE OR REPLACE VIEW "Stage".vw_monitoramento_cargas AS
SELECT carga_id, pipeline_run_id, entidade, ambiente, tabela_origem, tabela_destino,
       data_carga, quantidade_linhas, status_carga, data_inicio, data_fim,
       duracao_segundos, linhas_inseridas, linhas_atualizadas, linhas_rejeitadas,
       watermark_anterior, watermark_novo, mensagem_erro
FROM "Stage".controle_carga;

CREATE OR REPLACE VIEW "Produção".vw_qualidade_dados AS
SELECT 'Vendas sem cliente correspondente'::text AS validacao, COUNT(*)::bigint AS quantidade,
       CASE WHEN COUNT(*)=0 THEN 'OK' ELSE 'ALERTA' END::text AS status
FROM "Produção".fato_vendas f
LEFT JOIN "Produção".dim_cliente c ON c.cliente_key=f.cliente_key
WHERE c.cliente_key IS NULL
UNION ALL
SELECT 'Vendas sem produto correspondente', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'OK' ELSE 'ALERTA' END
FROM "Produção".fato_vendas f
LEFT JOIN "Produção".dim_produto p ON p.produto_key=f.produto_key
WHERE p.produto_key IS NULL
UNION ALL
SELECT 'Vendas sem vendedor correspondente', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'OK' ELSE 'ALERTA' END
FROM "Produção".fato_vendas f
LEFT JOIN "Produção".dim_vendedor v ON v.vendedor_key=f.vendedor_key
WHERE v.vendedor_key IS NULL
UNION ALL
SELECT 'Receita líquida negativa', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'OK' ELSE 'ALERTA' END
FROM "Produção".fato_vendas WHERE receita_liquida < 0
UNION ALL
SELECT 'Quantidade de venda inválida', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'OK' ELSE 'ALERTA' END
FROM "Produção".fato_vendas WHERE quantidade IS NULL OR quantidade <= 0;

CREATE OR REPLACE VIEW "Produção".vw_pipeline_health AS
SELECT
    MAX(data_fim) FILTER (WHERE status_carga='SUCESSO') AS ultima_carga_sucesso,
    COUNT(*) FILTER (WHERE status_carga='ERRO' AND data_inicio >= CURRENT_TIMESTAMP - INTERVAL '24 hours') AS erros_24h,
    COUNT(*) FILTER (WHERE status_carga='SUCESSO' AND data_inicio >= CURRENT_TIMESTAMP - INTERVAL '24 hours') AS sucessos_24h
FROM "Stage".controle_carga;
