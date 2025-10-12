-- ----------------------------------------------------------------
-- 1 Base de dados e criação de tabela
CREATE TABLE provap1 (
cod_vinho SERIAL PRIMARY KEY,
country VARCHAR(200),
description VARCHAR (2000),
points INT,
price FLOAT
);

-- ----------------------------------------------------------------
-- 2 Cursor não vinculado (cálculo de preço médio)
DO $$
DECLARE
    cur_paises REFCURSOR; 
    v_pais VARCHAR(100);
    v_preco_medio NUMERIC(10, 2);
BEGIN
    OPEN cur_paises FOR SELECT DISTINCT country FROM provap1;
    LOOP
        FETCH cur_paises INTO v_pais; 
        EXIT WHEN NOT FOUND; 
        SELECT AVG(price) INTO v_preco_medio FROM provap1 WHERE country = v_pais;
        INSERT INTO analise_vinhos (nome_pais, preco_medio) VALUES (v_pais, v_preco_medio);

        --RAISE NOTICE 'País: %, Preço Médio: %', v_pais, round(v_preco_medio, 2);

    END LOOP;
    CLOSE cur_paises;
END $$;


-- ----------------------------------------------------------------
-- 3 Cursor vinculado (Descrição mais longa)
DO $$
DECLARE
    cur_descricao CURSOR (p_pais VARCHAR) FOR 
        SELECT description 
        FROM provap1
        WHERE country = p_pais 
        ORDER BY LENGTH(description) DESC 
        LIMIT 1;
        
    v_registro_analise RECORD;
    v_descricao_longa TEXT;
BEGIN
    FOR v_registro_analise IN SELECT DISTINCT country FROM provap1 WHERE country IS NOT NULL LOOP
        OPEN cur_descricao(p_pais := v_registro_analise.country);
        FETCH cur_descricao INTO v_descricao_longa;
        CLOSE cur_descricao; 
        UPDATE analise_vinhos
        SET descricao_mais_longa = v_descricao_longa
        WHERE nome_pais = v_registro_analise.country;

        -- RAISE NOTICE 'País: %, Descrição Encontrada: %', v_registro_analise.country, v_descricao_longa;

    END LOOP;
END $$;

-- DO $$
-- DECLARE
--     cur_descricao CURSOR (p_pais VARCHAR) FOR 
--         SELECT description 
--         FROM provap1
--         WHERE country = p_pais 
--         ORDER BY LENGTH(description) DESC 
--         LIMIT 1;
--     v_registro_analise RECORD;
--     v_descricao_longa TEXT;
-- BEGIN
--     FOR v_registro_analise IN SELECT nome_pais FROM analise_vinhos LOOP
--         OPEN cur_descricao(p_pais := v_registro_analise.nome_pais);
--         FETCH cur_descricao INTO v_descricao_longa;
--         CLOSE cur_descricao; 
--         UPDATE analise_vinhos
--         SET descricao_mais_longa = v_descricao_longa
--         WHERE nome_pais = v_registro_analise.nome_pais;
--     END LOOP;
-- END $$;

-- ----------------------------------------------------------------
-- 4 Armazenamento dos resultados
CREATE TABLE analise_vinhos (
    cod_analise SERIAL PRIMARY KEY,
    nome_pais VARCHAR(100),
    preco_medio NUMERIC(10, 2),
    descricao_mais_longa TEXT
);

-- ----------------------------------------------------------------
-- 5 Exportação dos dados
-- Exportado csv, colocado no repositório
-- 
-- ----------------------------------------------------------------