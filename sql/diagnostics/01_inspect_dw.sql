-- Estrutura atual do DW
SELECT table_schema, table_name, column_name, data_type, is_nullable, ordinal_position
FROM information_schema.columns
WHERE table_schema IN ('Stage','Produção','Desenvolvimento')
ORDER BY table_schema, table_name, ordinal_position;

-- PKs, FKs e UNIQUEs
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con
JOIN pg_class c ON c.oid = con.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname IN ('Stage','Produção','Desenvolvimento')
ORDER BY schema_name, table_name, constraint_name;

-- Views atuais
SELECT schemaname, viewname, definition
FROM pg_views
WHERE schemaname IN ('Stage','Produção','Desenvolvimento')
ORDER BY schemaname, viewname;
