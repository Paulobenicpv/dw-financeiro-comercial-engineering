CREATE SCHEMA IF NOT EXISTS "Stage";
CREATE SCHEMA IF NOT EXISTS "Produção";
CREATE SCHEMA IF NOT EXISTS "Desenvolvimento";

CREATE TABLE IF NOT EXISTS "Stage".controle_carga (
    carga_id BIGSERIAL PRIMARY KEY,
    pipeline_run_id UUID,
    entidade VARCHAR(100),
    ambiente VARCHAR(50),
    tabela_origem VARCHAR(200),
    tabela_destino VARCHAR(200),
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantidade_linhas INTEGER DEFAULT 0,
    status_carga VARCHAR(30) DEFAULT 'EM_EXECUCAO',
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fim TIMESTAMP,
    duracao_segundos NUMERIC(14,3),
    linhas_inseridas INTEGER DEFAULT 0,
    linhas_atualizadas INTEGER DEFAULT 0,
    linhas_rejeitadas INTEGER DEFAULT 0,
    watermark_anterior TIMESTAMP,
    watermark_novo TIMESTAMP,
    mensagem_erro TEXT
);

ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS pipeline_run_id UUID;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS entidade VARCHAR(100);
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS data_inicio TIMESTAMP;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS data_fim TIMESTAMP;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS duracao_segundos NUMERIC(14,3);
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS linhas_inseridas INTEGER DEFAULT 0;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS linhas_atualizadas INTEGER DEFAULT 0;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS linhas_rejeitadas INTEGER DEFAULT 0;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS watermark_anterior TIMESTAMP;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS watermark_novo TIMESTAMP;
ALTER TABLE "Stage".controle_carga ADD COLUMN IF NOT EXISTS mensagem_erro TEXT;

CREATE TABLE IF NOT EXISTS "Stage".etl_watermark (
    entidade VARCHAR(100) PRIMARY KEY,
    coluna_watermark VARCHAR(100) NOT NULL,
    valor_watermark TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "Stage".dq_resultado (
    dq_id BIGSERIAL PRIMARY KEY,
    carga_id BIGINT REFERENCES "Stage".controle_carga(carga_id),
    entidade VARCHAR(100) NOT NULL,
    regra VARCHAR(250) NOT NULL,
    severidade VARCHAR(20) NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL,
    detalhes TEXT,
    executado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_controle_carga_pipeline_run ON "Stage".controle_carga(pipeline_run_id);
CREATE INDEX IF NOT EXISTS idx_controle_carga_status ON "Stage".controle_carga(status_carga);
CREATE INDEX IF NOT EXISTS idx_dq_resultado_carga ON "Stage".dq_resultado(carga_id);
