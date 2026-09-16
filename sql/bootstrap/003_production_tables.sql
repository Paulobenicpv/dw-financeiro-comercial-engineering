CREATE TABLE IF NOT EXISTS "Produção".dim_calendario (
    data_key INTEGER PRIMARY KEY,
    data DATE UNIQUE NOT NULL,
    ano INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    mes_nome VARCHAR(20) NOT NULL,
    trimestre INTEGER NOT NULL,
    ano_mes VARCHAR(7) NOT NULL,
    inicio_mes DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS "Produção".dim_cliente (
    cliente_key BIGSERIAL PRIMARY KEY,
    cliente_id BIGINT UNIQUE NOT NULL,
    nome_cliente VARCHAR(200) NOT NULL,
    segmento VARCHAR(100), porte VARCHAR(50), regiao VARCHAR(100), uf CHAR(2),
    dt_atualizacao_origem TIMESTAMP,
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_carga BIGINT
);

CREATE TABLE IF NOT EXISTS "Produção".dim_produto (
    produto_key BIGSERIAL PRIMARY KEY,
    produto_id BIGINT UNIQUE NOT NULL,
    produto VARCHAR(200) NOT NULL,
    categoria VARCHAR(100), subcategoria VARCHAR(100), custo_unitario NUMERIC(18,2),
    dt_atualizacao_origem TIMESTAMP,
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_carga BIGINT
);

CREATE TABLE IF NOT EXISTS "Produção".dim_vendedor (
    vendedor_key BIGSERIAL PRIMARY KEY,
    vendedor_id BIGINT UNIQUE NOT NULL,
    vendedor VARCHAR(200) NOT NULL,
    equipe VARCHAR(100), regiao VARCHAR(100),
    dt_atualizacao_origem TIMESTAMP,
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_carga BIGINT
);

CREATE TABLE IF NOT EXISTS "Produção".fato_vendas (
    venda_key BIGSERIAL PRIMARY KEY,
    codigo_venda BIGINT UNIQUE NOT NULL,
    data_key INTEGER NOT NULL REFERENCES "Produção".dim_calendario(data_key),
    cliente_key BIGINT NOT NULL REFERENCES "Produção".dim_cliente(cliente_key),
    produto_key BIGINT NOT NULL REFERENCES "Produção".dim_produto(produto_key),
    vendedor_key BIGINT NOT NULL REFERENCES "Produção".dim_vendedor(vendedor_key),
    canal VARCHAR(100),
    quantidade INTEGER NOT NULL,
    preco_unitario NUMERIC(18,2) NOT NULL,
    receita_bruta NUMERIC(18,2) NOT NULL,
    percentual_desconto NUMERIC(10,6) DEFAULT 0,
    valor_desconto NUMERIC(18,2) NOT NULL,
    receita_liquida NUMERIC(18,2) NOT NULL,
    custo_total NUMERIC(18,2) NOT NULL,
    lucro_bruto NUMERIC(18,2) NOT NULL,
    dt_atualizacao_origem TIMESTAMP,
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_carga BIGINT
);

CREATE TABLE IF NOT EXISTS "Produção".fato_metas (
    meta_key BIGSERIAL PRIMARY KEY,
    codigo_meta BIGINT UNIQUE NOT NULL,
    data_key INTEGER NOT NULL REFERENCES "Produção".dim_calendario(data_key),
    vendedor_key BIGINT NOT NULL REFERENCES "Produção".dim_vendedor(vendedor_key),
    meta_receita NUMERIC(18,2) NOT NULL,
    dt_atualizacao_origem TIMESTAMP,
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_carga BIGINT
);

CREATE TABLE IF NOT EXISTS "Produção".fato_despesas (
    despesa_key BIGSERIAL PRIMARY KEY,
    codigo_despesa BIGINT UNIQUE NOT NULL,
    data_key INTEGER NOT NULL REFERENCES "Produção".dim_calendario(data_key),
    centro_custo VARCHAR(100),
    tipo_despesa VARCHAR(100),
    classificacao VARCHAR(100),
    valor_despesa NUMERIC(18,2) NOT NULL,
    dt_atualizacao_origem TIMESTAMP,
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_carga BIGINT
);

CREATE INDEX IF NOT EXISTS idx_fato_vendas_data ON "Produção".fato_vendas(data_key);
CREATE INDEX IF NOT EXISTS idx_fato_vendas_cliente ON "Produção".fato_vendas(cliente_key);
CREATE INDEX IF NOT EXISTS idx_fato_vendas_produto ON "Produção".fato_vendas(produto_key);
CREATE INDEX IF NOT EXISTS idx_fato_vendas_vendedor ON "Produção".fato_vendas(vendedor_key);
CREATE INDEX IF NOT EXISTS idx_fato_metas_data ON "Produção".fato_metas(data_key);
CREATE INDEX IF NOT EXISTS idx_fato_metas_vendedor ON "Produção".fato_metas(vendedor_key);
CREATE INDEX IF NOT EXISTS idx_fato_despesas_data ON "Produção".fato_despesas(data_key);
