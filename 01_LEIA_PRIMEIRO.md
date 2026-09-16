# Antes de apontar para o seu DW atual

O projeto está completo e executável em modo demonstração. Para ligar na sua estrutura real sem quebrar o que já existe, faça primeiro uma etapa de mapeamento.

## Ordem segura

1. Execute `sql/diagnostics/01_inspect_dw.sql` no seu `dw_financeiro_comercial`.
2. Execute `sql/diagnostics/02_inspect_source.sql` no banco de origem.
3. Compare os nomes reais com `config/entities.yml`.
4. Ajuste os SQLs de transformação somente se o seu schema atual usar nomes de colunas diferentes dos exemplos do projeto.
5. Faça backup/snapshot do banco.
6. Rode `scripts/check_connections.py`.
7. Rode `scripts/bootstrap.py` primeiro em Desenvolvimento.
8. Rode o pipeline em Desenvolvimento.
9. Valide contagem, valores e Data Quality.
10. Só depois promova para Produção.

**Não execute o bootstrap diretamente em Produção antes de validar o mapeamento das colunas do seu DW atual.**
