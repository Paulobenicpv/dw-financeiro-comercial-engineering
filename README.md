# DW Financeiro Comercial — Engenharia de Dados

![CI](https://github.com/Paulobenicpv/dw-financeiro-comercial-engineering/actions/workflows/ci.yml/badge.svg)

Projeto de Engenharia de Dados desenvolvido para simular uma arquitetura corporativa de dados financeiros e comerciais, desde a origem transacional até a disponibilização das informações para análise no Power BI.

O projeto implementa ingestão incremental, Data Warehouse dimensional, controle de watermark, auditoria, qualidade de dados, orquestração com Prefect, execução com Docker e CI automatizado pelo GitHub Actions.

---

## Arquitetura

```text
PostgreSQL OLTP
oltp_financeiro_comercial
        │
        ▼
Source Contract
vw_etl_*
        │
        ▼
Python ETL Incremental
        │
        ▼
Stage / Landing
        │
        ├── Controle de Carga
        ├── Watermark
        └── Data Quality
        │
        ▼
Data Warehouse
dw_financeiro_comercial
        │
        ▼
Views Analíticas
        │
        ▼
Power BI Desktop
```

A execução e a orquestração do pipeline são realizadas através de:

```text
Docker Compose
   │
   ├── Prefect Server
   │      └── UI / Logs / Histórico
   │
   └── Pipeline Python
          └── Deployment Prefect
```

---

## Principais recursos

O projeto possui:

- Pipeline ETL/ELT desenvolvido em Python.
- Extração incremental utilizando watermark.
- Processamento independente por entidade.
- Camada Source Contract através de views PostgreSQL.
- Landing/Stage para processamento dos dados.
- Data Warehouse dimensional.
- Controle de cargas e auditoria.
- Validações de Data Quality.
- Estratégia de UPSERT.
- Logs estruturados.
- Orquestração com Prefect.
- Retries automáticos em caso de falha.
- Deployment e execução agendada.
- Containerização com Docker.
- Healthcheck do Prefect Server.
- Docker Compose para gerenciamento dos serviços.
- Testes automatizados com Pytest.
- CI utilizando GitHub Actions.
- Validação automática do Docker Build.
- Proteção de credenciais através de variáveis de ambiente.

---

## Tecnologias

**Engenharia de Dados**

`Python` `SQL` `PostgreSQL` `SQLAlchemy` `Pandas`

**Orquestração**

`Prefect`

**DevOps**

`Docker` `Docker Compose` `Git` `GitHub` `GitHub Actions`

**Qualidade**

`Pytest` `Data Quality Checks` `Auditoria`

**Analytics**

`Power BI`

---

## Estrutura do projeto

```text
dw-financeiro-comercial-engineering/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── config/
│   └── entities.yml
│
├── docs/
│   ├── architecture.md
│   ├── data_contract.md
│   ├── docker_local.md
│   └── runbook.md
│
├── orchestration/
│   └── prefect_flow.py
│
├── scripts/
│   ├── bootstrap.py
│   ├── check_connections.py
│   └── run_pipeline.py
│
├── sql/
│   ├── bootstrap/
│   ├── diagnostics/
│   ├── source_contract/
│   ├── source_seed/
│   └── transform/
│
├── src/
│   └── dw_pipeline/
│       ├── audit.py
│       ├── config.py
│       ├── db.py
│       ├── extract.py
│       ├── load_stage.py
│       ├── logging_config.py
│       ├── pipeline.py
│       ├── powerbi.py
│       ├── quality.py
│       └── transform.py
│
├── tests/
│
├── .env.example
├── .gitignore
├── .dockerignore
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── README.md
```

---

## Bancos de dados

O projeto utiliza dois bancos PostgreSQL.

### Origem

```text
oltp_financeiro_comercial
```

Representa o sistema transacional da empresa.

Principais entidades:

```text
clientes
produtos
vendedores
vendas
itens_venda
metas
despesas
```

### Data Warehouse

```text
dw_financeiro_comercial
```

Modelo dimensional destinado ao consumo analítico.

Principais dimensões:

```text
dim_calendario
dim_cliente
dim_produto
dim_vendedor
```

Principais fatos:

```text
fato_vendas
fato_metas
fato_despesas
```

---

## Source Contract

O ETL não depende diretamente das tabelas transacionais.

Foi criada uma camada de contrato através das views:

```text
vw_etl_clientes
vw_etl_produtos
vw_etl_vendedores
vw_etl_vendas
vw_etl_metas
vw_etl_despesas
```

Essa abordagem desacopla o pipeline da estrutura física do sistema de origem e cria uma interface estável para ingestão.

---

## Processamento incremental

O pipeline utiliza controle de **watermark** baseado em data de atualização.

Em cada execução são processados somente registros novos ou alterados desde a última carga bem-sucedida.

Exemplo:

```text
1ª execução
40.000 registros processados

2ª execução
0 registros alterados
→ nenhuma carga desnecessária

Registro atualizado na origem
→ somente o registro alterado é reprocessado
```

Isso reduz processamento e aproxima o projeto de cenários reais de Engenharia de Dados.

---

## Data Quality

Antes da disponibilização dos dados em Produção, o pipeline executa validações de qualidade.

São verificadas situações como:

```text
Campos obrigatórios
Duplicidade de chave de negócio
Valores inválidos
Valores negativos indevidos
Integridade entre fatos e dimensões
```

Os resultados são registrados na tabela:

```text
Stage.dq_resultado
```

---

## Auditoria

Cada execução gera informações de auditoria, incluindo:

```text
ID da carga
Data de início
Data de término
Duração
Linhas processadas
Linhas inseridas
Linhas atualizadas
Linhas rejeitadas
Status
Mensagem de erro
```

Essas informações permitem rastrear e monitorar as execuções do pipeline.

---

## Orquestração com Prefect

O pipeline é orquestrado utilizando Prefect.

O deployment utilizado é:

```text
dw-financeiro-comercial-producao
```

A execução está configurada para ocorrer diariamente às:

```text
06:00
America/Sao_Paulo
```

O Prefect permite acompanhar:

```text
Execuções
Status
Logs
Falhas
Retries
Histórico
Tempo de processamento
```

---

## Docker

Os componentes de Engenharia de Dados são executados através do Docker Compose.

Arquitetura local:

```text
Windows
│
├── PostgreSQL
│   ├── oltp_financeiro_comercial
│   └── dw_financeiro_comercial
│
└── Docker
    ├── dwfc-prefect-server
    └── dwfc-pipeline
```

Os containers acessam o PostgreSQL do host através de:

```text
host.docker.internal
```

---

## Healthcheck

O Prefect Server possui healthcheck configurado.

O container do pipeline somente inicia quando a API do Prefect estiver saudável.

```text
Prefect Server inicia
        ↓
Healthcheck
        ↓
Healthy
        ↓
Pipeline inicia
```

---

## CI — GitHub Actions

O projeto possui pipeline de integração contínua executada automaticamente a cada `push` ou `pull request`.

O CI realiza:

```text
Checkout do código
        ↓
Configuração do Python
        ↓
Instalação das dependências
        ↓
Validação de compilação
        ↓
Pytest
        ↓
Docker Build
```

Somente código validado passa por todas as etapas.

---

## Segurança

Credenciais não são armazenadas no código-fonte.

O projeto utiliza variáveis de ambiente:

```text
SOURCE_DB_USER
SOURCE_DB_PASSWORD
DW_DB_USER
DW_DB_PASSWORD
```

O arquivo real:

```text
.env
```

é ignorado pelo Git.

Somente o modelo:

```text
.env.example
```

é versionado.

Nenhuma senha, token ou credencial real deve ser adicionada ao repositório.

---

## Configuração

Crie o arquivo `.env` a partir do exemplo:

```bash
cp .env.example .env
```

Configure suas próprias credenciais PostgreSQL.

Exemplo:

```env
SOURCE_DB_HOST=localhost
SOURCE_DB_PORT=5432
SOURCE_DB_NAME=oltp_financeiro_comercial
SOURCE_DB_USER=seu_usuario
SOURCE_DB_PASSWORD=sua_senha

DW_DB_HOST=localhost
DW_DB_PORT=5432
DW_DB_NAME=dw_financeiro_comercial
DW_DB_USER=seu_usuario
DW_DB_PASSWORD=sua_senha
```

---

## Executando com Docker

Build:

```bash
docker compose build pipeline
```

Subir os serviços:

```bash
docker compose up -d
```

Verificar:

```bash
docker compose ps
```

Logs:

```bash
docker compose logs -f pipeline
```

Interface do Prefect:

```text
http://127.0.0.1:4200
```

---

## Testes

Executar os testes localmente:

```bash
pytest -q
```

Ou:

```bash
PYTHONPATH=src pytest -q
```

---

## Camada analítica

O Data Warehouse disponibiliza views preparadas para consumo pelo Power BI:

```text
vw_financeiro_comercial
vw_indicadores_financeiro_comercial
vw_qualidade_dados
```

O relatório analítico foi desenvolvido no Power BI Desktop para análises financeiras, comerciais, metas, clientes, produtos e evolução temporal.

---

## Objetivo do projeto

Este projeto foi desenvolvido como estudo prático e portfólio de Engenharia de Dados e Business Intelligence, aplicando conceitos utilizados em ambientes corporativos:

```text
Arquitetura de Dados
ETL Incremental
Data Warehouse
Modelagem Dimensional
Data Quality
Observabilidade
Orquestração
Containerização
CI/CD
Analytics
```

---

## Autor

**Paulo Beni**

Data & BI | Engenharia de Dados | Business Intelligence

GitHub: [Paulobenicpv](https://github.com/Paulobenicpv)