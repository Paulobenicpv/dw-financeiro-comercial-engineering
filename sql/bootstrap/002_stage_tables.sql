-- Landing tables inside Stage. They preserve source natural keys and are safe to recreate/upsert.
CREATE TABLE IF NOT EXISTS "Stage".lnd_dim_cliente (
    source_cliente_id BIGINT PRIMARY KEY,
    codigo_cliente VARCHAR(60) NOT NULL,
    nome_cliente VARCHAR(200) NOT NULL,
    segmento VARCHAR(100), porte VARCHAR(50), regiao VARCHAR(100), uf VARCHAR(10), cidade VARCHAR(120), status_cliente VARCHAR(50),
    dt_atualizacao TIMESTAMP NOT NULL,
    id_carga BIGINT REFERENCES "Stage".controle_carga(carga_id),
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sistema_origem VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS "Stage".lnd_dim_produto (
    source_produto_id BIGINT PRIMARY KEY,
    codigo_produto VARCHAR(60) NOT NULL,
    produto VARCHAR(200) NOT NULL,
    categoria VARCHAR(100), subcategoria VARCHAR(100), preco_lista NUMERIC(18,2), custo_padrao NUMERIC(18,2),
    dt_atualizacao TIMESTAMP NOT NULL,
    id_carga BIGINT REFERENCES "Stage".controle_carga(carga_id),
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sistema_origem VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS "Stage".lnd_dim_vendedor (
    source_vendedor_id BIGINT PRIMARY KEY,
    codigo_vendedor VARCHAR(60) NOT NULL,
    vendedor VARCHAR(200) NOT NULL,
    regiao VARCHAR(100), equipe VARCHAR(100), cargo VARCHAR(100), data_admissao DATE,
    dt_atualizacao TIMESTAMP NOT NULL,
    id_carga BIGINT REFERENCES "Stage".controle_carga(carga_id),
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sistema_origem VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS "Stage".lnd_fato_vendas (
    source_item_id BIGINT PRIMARY KEY,
    codigo_venda VARCHAR(80) NOT NULL,
    data_venda DATE NOT NULL,
    codigo_cliente VARCHAR(60) NOT NULL,
    codigo_produto VARCHAR(60) NOT NULL,
    codigo_vendedor VARCHAR(60) NOT NULL,
    canal VARCHAR(100),
    quantidade INTEGER NOT NULL,
    preco_unitario NUMERIC(18,2) NOT NULL,
    percentual_desconto NUMERIC(10,6) DEFAULT 0,
    forma_pagamento VARCHAR(100),
    prazo_recebimento_dias INTEGER,
    status_venda VARCHAR(50),
    tipo_cliente VARCHAR(100),
    dt_atualizacao TIMESTAMP NOT NULL,
    id_carga BIGINT REFERENCES "Stage".controle_carga(carga_id),
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sistema_origem VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS "Stage".lnd_fato_metas (
    source_meta_id BIGINT PRIMARY KEY,
    codigo_meta VARCHAR(80) NOT NULL,
    data_meta DATE NOT NULL,
    codigo_vendedor VARCHAR(60) NOT NULL,
    meta_receita NUMERIC(18,2) NOT NULL,
    meta_margem NUMERIC(12,6) DEFAULT 0,
    meta_novos_clientes INTEGER DEFAULT 0,
    dt_atualizacao TIMESTAMP NOT NULL,
    id_carga BIGINT REFERENCES "Stage".controle_carga(carga_id),
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sistema_origem VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS "Stage".lnd_fato_despesas (
    source_despesa_id BIGINT PRIMARY KEY,
    codigo_despesa VARCHAR(80) NOT NULL,
    data_despesa DATE NOT NULL,
    centro_custo VARCHAR(100),
    tipo_despesa VARCHAR(100),
    classificacao VARCHAR(100),
    valor_despesa NUMERIC(18,2) NOT NULL,
    dt_atualizacao TIMESTAMP NOT NULL,
    id_carga BIGINT REFERENCES "Stage".controle_carga(carga_id),
    dt_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sistema_origem VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_lnd_vendas_data ON "Stage".lnd_fato_vendas(data_venda);
CREATE INDEX IF NOT EXISTS idx_lnd_vendas_cod_cliente ON "Stage".lnd_fato_vendas(codigo_cliente);
CREATE INDEX IF NOT EXISTS idx_lnd_vendas_cod_produto ON "Stage".lnd_fato_vendas(codigo_produto);
CREATE INDEX IF NOT EXISTS idx_lnd_vendas_cod_vendedor ON "Stage".lnd_fato_vendas(codigo_vendedor);
