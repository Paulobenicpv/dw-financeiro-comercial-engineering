# Contrato de dados da origem

| Entidade | Chave de negócio | Watermark | Campos mínimos |
|---|---|---|---|
| clientes | cliente_id | dt_atualizacao | cliente_id, nome_cliente |
| produtos | produto_id | dt_atualizacao | produto_id, produto, custo_unitario |
| vendedores | vendedor_id | dt_atualizacao | vendedor_id, vendedor |
| vendas | venda_id | dt_atualizacao | venda_id, data_venda, cliente_id, produto_id, vendedor_id, quantidade, preco_unitario |
| metas | meta_id | dt_atualizacao | meta_id, data_meta, vendedor_id, meta_receita |
| despesas | despesa_id | dt_atualizacao | despesa_id, data_despesa, valor_despesa |

A incrementalidade usa:

```sql
WHERE dt_atualizacao > :ultimo_watermark
```

Se a origem não tiver `dt_atualizacao`, prefira CDC ou uma chave sequencial monotônica em vez de usar apenas data de criação.
