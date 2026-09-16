CREATE TABLE clientes (
  cliente_id BIGINT PRIMARY KEY,
  nome_cliente VARCHAR(200),
  segmento VARCHAR(100),
  porte VARCHAR(50),
  regiao VARCHAR(100),
  uf CHAR(2),
  dt_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE produtos (
  produto_id BIGINT PRIMARY KEY,
  produto VARCHAR(200),
  categoria VARCHAR(100),
  subcategoria VARCHAR(100),
  custo_unitario NUMERIC(18,2),
  dt_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vendedores (
  vendedor_id BIGINT PRIMARY KEY,
  vendedor VARCHAR(200),
  equipe VARCHAR(100),
  regiao VARCHAR(100),
  dt_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vendas (
  venda_id BIGINT PRIMARY KEY,
  data_venda DATE,
  cliente_id BIGINT REFERENCES clientes,
  produto_id BIGINT REFERENCES produtos,
  vendedor_id BIGINT REFERENCES vendedores,
  canal VARCHAR(100),
  quantidade INTEGER,
  preco_unitario NUMERIC(18,2),
  percentual_desconto NUMERIC(10,6),
  dt_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE metas (
  meta_id BIGINT PRIMARY KEY,
  data_meta DATE,
  vendedor_id BIGINT REFERENCES vendedores,
  meta_receita NUMERIC(18,2),
  dt_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE despesas (
  despesa_id BIGINT PRIMARY KEY,
  data_despesa DATE,
  centro_custo VARCHAR(100),
  tipo_despesa VARCHAR(100),
  classificacao VARCHAR(100),
  valor_despesa NUMERIC(18,2),
  dt_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO clientes
SELECT i, 'Cliente '||i,
       (ARRAY['Varejo','Enterprise','PME'])[1+(i%3)],
       (ARRAY['Pequeno','Médio','Grande'])[1+(i%3)],
       (ARRAY['Sudeste','Sul','Nordeste','Centro-Oeste'])[1+(i%4)],
       (ARRAY['SP','RJ','MG','PR','SC','BA','GO'])[1+(i%7)],
       CURRENT_TIMESTAMP
FROM generate_series(1,30) i;

INSERT INTO produtos
SELECT i, 'Produto '||i,
       (ARRAY['Software','Serviços','Hardware'])[1+(i%3)],
       (ARRAY['Premium','Standard','Essencial'])[1+(i%3)],
       50 + (i*7.5),
       CURRENT_TIMESTAMP
FROM generate_series(1,25) i;

INSERT INTO vendedores
SELECT i, 'Vendedor '||i,
       (ARRAY['Equipe A','Equipe B','Equipe C'])[1+(i%3)],
       (ARRAY['Sudeste','Sul','Nordeste'])[1+(i%3)],
       CURRENT_TIMESTAMP
FROM generate_series(1,10) i;

INSERT INTO vendas
SELECT i,
       DATE '2025-01-01' + (i % 620),
       1+(i%30),
       1+(i%25),
       1+(i%10),
       (ARRAY['Online','Parceiros','Direto'])[1+(i%3)],
       1+(i%8),
       120 + ((i%25)*17.3),
       CASE WHEN i%5=0 THEN 0.10 ELSE 0.03 END,
       CURRENT_TIMESTAMP
FROM generate_series(1,2500) i;

INSERT INTO metas
SELECT row_number() OVER (), m::date, v, 35000 + v*1500, CURRENT_TIMESTAMP
FROM generate_series(DATE '2025-01-01', DATE '2026-12-01', INTERVAL '1 month') m
CROSS JOIN generate_series(1,10) v;

INSERT INTO despesas
SELECT i,
       DATE '2025-01-01' + (i%620),
       (ARRAY['Comercial','Tecnologia','Administrativo','Marketing'])[1+(i%4)],
       (ARRAY['Pessoal','Infraestrutura','Marketing','Serviços'])[1+(i%4)],
       (ARRAY['Fixa','Variável'])[1+(i%2)],
       500 + (i%20)*125,
       CURRENT_TIMESTAMP
FROM generate_series(1,500) i;
