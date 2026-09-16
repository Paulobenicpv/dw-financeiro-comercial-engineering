# Docker local — PostgreSQL no Windows

Esta configuração mantém os bancos PostgreSQL existentes no Windows e containeriza apenas o Prefect Server e o processo do pipeline.

## Arquitetura

PostgreSQL Windows (`oltp_financeiro_comercial` + `dw_financeiro_comercial`) <- `host.docker.internal:5432` <- container `pipeline` -> container `prefect-server`

## Pré-requisitos

- Docker Desktop em execução
- PostgreSQL do Windows em execução na porta 5432
- arquivo `.env` na raiz com os nomes dos bancos, usuário e senha já validados

O `docker-compose.yml` sobrescreve apenas os hosts de banco para `host.docker.internal`; portanto o mesmo `.env` pode continuar usando suas credenciais atuais.

## Subir

Antes, encerre o `prefect server start` que estiver usando a porta 4200 no Windows. Depois:

```powershell
docker compose build
docker compose up -d
```

## Validar

```powershell
docker compose ps
docker compose logs -f pipeline
```

Prefect UI: `http://127.0.0.1:4200`

## Parar

```powershell
docker compose down
```

Os bancos não são removidos, porque continuam fora do Docker. Os metadados do Prefect ficam no volume nomeado `prefect_data`.

## Segurança

O `.env` não entra na imagem Docker graças ao `.dockerignore` e não deve ser enviado ao Git. Ambientes virtuais `.venv*`, caches e o PBIX também não entram no build.
