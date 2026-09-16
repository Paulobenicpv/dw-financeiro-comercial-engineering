from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote_plus
import os

import yaml
from dotenv import load_dotenv


# ============================================================
# CARREGAMENTO DAS VARIÁVEIS DE AMBIENTE
# ============================================================
#
# Em desenvolvimento local:
#   lê o arquivo .env
#
# Em Docker / CI/CD / Produção:
#   utiliza as variáveis de ambiente disponíveis no processo.
#
# O arquivo .env NÃO deve ser versionado no Git.
# ============================================================

load_dotenv()


@dataclass(frozen=True)
class Settings:

    # ========================================================
    # BANCO DE ORIGEM - OLTP
    # ========================================================

    source_db_host: str = os.getenv(
        "SOURCE_DB_HOST",
        "localhost"
    )

    source_db_port: int = int(
        os.getenv(
            "SOURCE_DB_PORT",
            "5432"
        )
    )

    source_db_name: str = os.getenv(
        "SOURCE_DB_NAME",
        "oltp_financeiro_comercial"
    )

    # Usuário e senha não possuem valores padrão.
    # Devem ser informados via .env ou variável de ambiente.
    source_db_user: str = os.getenv(
        "SOURCE_DB_USER",
        ""
    )

    source_db_password: str = os.getenv(
        "SOURCE_DB_PASSWORD",
        ""
    )

    source_system_name: str = os.getenv(
        "SOURCE_SYSTEM_NAME",
        "OLTP_FINANCEIRO_COMERCIAL"
    )


    # ========================================================
    # DATA WAREHOUSE
    # ========================================================

    dw_db_host: str = os.getenv(
        "DW_DB_HOST",
        "localhost"
    )

    dw_db_port: int = int(
        os.getenv(
            "DW_DB_PORT",
            "5432"
        )
    )

    dw_db_name: str = os.getenv(
        "DW_DB_NAME",
        "dw_financeiro_comercial"
    )

    # Usuário e senha não possuem valores padrão.
    dw_db_user: str = os.getenv(
        "DW_DB_USER",
        ""
    )

    dw_db_password: str = os.getenv(
        "DW_DB_PASSWORD",
        ""
    )


    # ========================================================
    # SCHEMAS
    # ========================================================

    stage_schema: str = os.getenv(
        "STAGE_SCHEMA",
        "Stage"
    )

    prod_schema: str = os.getenv(
        "PROD_SCHEMA",
        "Produção"
    )


    # ========================================================
    # AMBIENTE
    # ========================================================

    environment: str = os.getenv(
        "ENVIRONMENT",
        "PRODUCAO"
    )

    entities_config: str = os.getenv(
        "ENTITIES_CONFIG",
        "config/entities.yml"
    )

    log_level: str = os.getenv(
        "LOG_LEVEL",
        "INFO"
    )


    # ========================================================
    # POWER BI
    # ========================================================

    powerbi_refresh_enabled: bool = (
        os.getenv(
            "POWERBI_REFRESH_ENABLED",
            "false"
        ).strip().lower()
        in {"true", "1", "yes", "sim"}
    )

    powerbi_tenant_id: str = os.getenv(
        "POWERBI_TENANT_ID",
        ""
    )

    powerbi_client_id: str = os.getenv(
        "POWERBI_CLIENT_ID",
        ""
    )

    powerbi_client_secret: str = os.getenv(
        "POWERBI_CLIENT_SECRET",
        ""
    )

    powerbi_workspace_id: str = os.getenv(
        "POWERBI_WORKSPACE_ID",
        ""
    )

    powerbi_dataset_id: str = os.getenv(
        "POWERBI_DATASET_ID",
        ""
    )


    # ========================================================
    # VALIDAÇÃO DAS CREDENCIAIS
    # ========================================================

    def validate_database_credentials(self) -> None:
        """
        Valida se as credenciais obrigatórias dos bancos
        foram fornecidas pelas variáveis de ambiente.

        Nenhuma credencial fica gravada diretamente no código.
        """

        missing = []

        if not self.source_db_user:
            missing.append("SOURCE_DB_USER")

        if not self.source_db_password:
            missing.append("SOURCE_DB_PASSWORD")

        if not self.dw_db_user:
            missing.append("DW_DB_USER")

        if not self.dw_db_password:
            missing.append("DW_DB_PASSWORD")

        if missing:
            raise ValueError(
                "Variáveis de ambiente obrigatórias não configuradas: "
                + ", ".join(missing)
            )


    # ========================================================
    # URL BANCO DE ORIGEM
    # ========================================================

    @property
    def source_url(self) -> str:
        """
        Retorna a string de conexão do banco de origem.

        quote_plus protege a URL caso usuário ou senha possuam
        caracteres especiais.
        """

        self.validate_database_credentials()

        user = quote_plus(self.source_db_user)
        password = quote_plus(self.source_db_password)

        return (
            f"postgresql+psycopg2://"
            f"{user}:{password}"
            f"@{self.source_db_host}:"
            f"{self.source_db_port}/"
            f"{self.source_db_name}"
        )


    # ========================================================
    # URL DATA WAREHOUSE
    # ========================================================

    @property
    def dw_url(self) -> str:
        """
        Retorna a string de conexão do Data Warehouse.
        """

        self.validate_database_credentials()

        user = quote_plus(self.dw_db_user)
        password = quote_plus(self.dw_db_password)

        return (
            f"postgresql+psycopg2://"
            f"{user}:{password}"
            f"@{self.dw_db_host}:"
            f"{self.dw_db_port}/"
            f"{self.dw_db_name}"
        )


# ============================================================
# CARREGAMENTO DA CONFIGURAÇÃO DAS ENTIDADES
# ============================================================

def load_entities(path: str | None = None) -> dict:
    """
    Carrega a configuração das entidades do pipeline
    definida em config/entities.yml.
    """

    settings = Settings()

    cfg_path = Path(
        path or settings.entities_config
    )

    if not cfg_path.exists():
        raise FileNotFoundError(
            f"Arquivo de configuração não encontrado: {cfg_path}"
        )

    with cfg_path.open(
        "r",
        encoding="utf-8"
    ) as file:
        data = yaml.safe_load(file) or {}

    entities = data.get(
        "entities",
        {}
    )

    if not entities:
        raise ValueError(
            "Nenhuma entidade definida em config/entities.yml"
        )

    return dict(
        sorted(
            entities.items(),
            key=lambda item: item[1].get(
                "order",
                999
            )
        )
    )