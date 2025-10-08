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
    v_pais TEXT;
    cur_precos REFCURSOR;
    v_preco NUMERIC(10, 2);
    v_soma_precos NUMERIC(10, 2);
    v_contador INT;
    v_media NUMERIC(10, 2);
BEGIN
    OPEN cur_paises;
    LOOP
        FETCH cur_paises INTO v_pais;
        EXIT WHEN NOT FOUND;
        v_soma_precos := 0;
        v_contador := 0;
        OPEN cur_precos FOR EXECUTE
            format(
                '
                SELECT price FROM tb_vinhos WHERE country = %L AND price IS NOT NULL
                ', v_pais);
        LOOP
            FETCH cur_precos INTO v_preco;
            EXIT WHEN NOT FOUND;
            v_soma_precos := v_soma_precos + v_preco;
            v_contador := v_contador + 1;
        END LOOP;
        CLOSE cur_precos;
        IF v_contador > 0 THEN
            v_media := v_soma_precos / v_contador;
            INSERT INTO tb_resultados_paises (nome_pais, preco_medio) VALUES (v_pais, v_media);
        END IF;
    END LOOP;
    CLOSE cur_paises;
END; $$


-- ----------------------------------------------------------------
-- 3 Cursor vinculado (Descrição mais longa)
--escreva a sua solução aqui
DO $$
DECLARE
    cur_paises CURSOR FOR SELECT DISTINCT country FROM tb_vinhos WHERE country IS NOT NULL;
    v_pais TEXT;
    cur_precos REFCURSOR;
    v_preco NUMERIC(10, 2);
    v_soma_precos NUMERIC(10, 2);
    v_contador INT;
    v_media NUMERIC(10, 2);
BEGIN
    OPEN cur_paises;
    LOOP
        FETCH cur_paises INTO v_pais;
        EXIT WHEN NOT FOUND;
        v_soma_precos := 0;
        v_contador := 0;
        OPEN cur_precos FOR EXECUTE
            format(
                '
                SELECT price FROM tb_vinhos WHERE country = %L AND price IS NOT NULL
                ', v_pais);
        LOOP
            FETCH cur_precos INTO v_preco;
            EXIT WHEN NOT FOUND;
            v_soma_precos := v_soma_precos + v_preco;
            v_contador := v_contador + 1;
        END LOOP;
        CLOSE cur_precos;
        IF v_contador > 0 THEN
            v_media := v_soma_precos / v_contador;
            INSERT INTO tb_resultados_paises (nome_pais, preco_medio) VALUES (v_pais, v_media);
        END IF;
    END LOOP;
    CLOSE cur_paises;
END; $$


-- ----------------------------------------------------------------
-- 4 Armazenamento dos resultados
CREATE TABLE(
id SERIAL PRIMARY KEY,
nome_pais VARCHAR(200),
preco_medio VARCHAR(200),
descricao_mais_longa VARCHAR(2000)
);


-- ----------------------------------------------------------------
-- 5 Exportação dos dados
--escreva a sua solução aqui
-- 
-- ----------------------------------------------------------------