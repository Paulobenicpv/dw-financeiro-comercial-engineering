# Arquitetura de referência

## Camadas

**Origem** — banco transacional. O pipeline é somente leitura na origem.

**Stage** — aterrissagem e padronização com upsert por chave de negócio e rastreabilidade por carga.

**Data Quality** — regras críticas antes da publicação. Falha bloqueia Produção.

**Produção** — modelo dimensional com dimensões conformadas, fatos e chaves substitutas.

**Views** — monitoramento e camada analítica para consumo.

**Power BI** — modelo semântico, DAX e experiência executiva.

## Decisões de engenharia

- Watermark avança somente após transformação bem-sucedida.
- Dimensões carregam antes das fatos.
- Rerun é seguro por causa do upsert.
- Data Quality é gate de publicação.
- Auditoria registra início, fim, duração, linhas inseridas, atualizadas, rejeitadas e mensagem de erro.
- Segredos ficam em variáveis de ambiente.
- Refresh do Power BI acontece depois do DW estar consistente.

## Próximas evoluções empresariais

- SCD Type 2 para dimensões que precisam de histórico
- CDC/Debezium para baixa latência
- dbt para transformação e testes em times maiores
- OpenTelemetry/Prometheus/Grafana para observabilidade
- Vault/Secrets Manager para credenciais
- CI/CD com DEV/HML/PRD e aprovação de deploy
