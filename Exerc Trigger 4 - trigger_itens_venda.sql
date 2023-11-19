/* Exercício 4:

Você está desenvolvendo um sistema de gerenciamento de estoque para uma loja de eletrônicos. 
O sistema possui as seguintes tabelas:

Tabela "produtos":
- Colunas: id_produto (chave primária), nome (varchar), quantidade_estoque (int)

Tabela "vendas":
- Colunas: id_venda (chave primária), data_venda (datetime)

Tabela "itens_venda":
- Colunas: id_item_venda (chave primária), id_venda (chave estrangeira referenciando a tabela "vendas"), 
id_produto (chave estrangeira referenciando a tabela "produtos"), quantidade (int)

Crie um trigger que, ao inserir um novo item de venda na tabela "itens_venda", 
verifique se a quantidade em estoque do produto correspondente é suficiente para a venda. 
Se não for, retorne um erro informando que o produto está fora de estoque.

*/

CREATE DATABASE atividade_triggerii;

USE atividade_triggerii;

-- INÍCIO DA EXECUÇÃO

-- Criar tabela produtos
CREATE TABLE produtos(
id_produto INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(255) NOT NULL,
quantidade_estoque INT NOT NULL
);

-- Criar tabela vendas
CREATE TABLE vendas(
id_venda INT PRIMARY KEY,
data_venda DATETIME NOT NULL 
);

-- Criar tabela itens_venda
CREATE TABLE itens_venda(
id_item_venda INT PRIMARY KEY AUTO_INCREMENT,
id_venda INT NOT NULL,
id_produto INT NOT NULL,
quantidade INT NOT NULL,
FOREIGN KEY(id_produto) REFERENCES produtos(id_produto),
FOREIGN KEY(id_venda)REFERENCES vendas(id_venda)
);

/* Criar TRIGGER que após o registro de uma venda de um produto no itens_venda, diminui a quantidade vendida no estoque
(tabela produtos) do produto correspondente. Além disso, registra a venda do item na tabela vendas.

*/
DELIMITER //

CREATE TRIGGER tg_cadastrar_venda
BEFORE INSERT ON itens_venda
FOR EACH ROW
BEGIN
		DECLARE qtd_estoque_atual int;
		SELECT quantidade_estoque INTO qtd_estoque_atual FROM produtos WHERE id_produto = NEW.id_produto;
		IF (NEW.quantidade > qtd_estoque_atual) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venda negada. Quantidade de estoque do produto insuficiente.';
		ELSE
			IF (NEW.quantidade <= 0) THEN
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venda negada. No mínimo 1 produto precisa ser vendido.';
			ELSE 
					UPDATE produtos
					SET quantidade_estoque = quantidade_estoque - New.quantidade WHERE id_produto = NEW.id_produto;
					INSERT INTO vendas (id_venda, data_venda) VALUES (NEW.id_venda, NOW());
			END IF;
        END IF;
END//

DELIMITER ;


-- Inserir dois produtos no estoque (tabela produtos)
INSERT INTO produtos (id_produto, nome, quantidade_estoque) VALUES
(1, 'Teclado Mecânico', 100),
(2, 'Mouse 4000dpi', 200);

-- Exibir tabela produtos antes dos INSERTS na tabela itens_venda e o efeito do TRIGGER
SELECT * FROM produtos;

/* 1° Venda de 10 unidades do produto de id 1 (Teclado Mecânico),
2° Venda de 20 unidades do produto de id 2 (Mouse 4000 dpi) e
3° Venda de +50 unidades do produto de id 1 (Teclado Mecânico) da
tabela produtos */
INSERT INTO itens_venda (id_venda, id_produto, quantidade) VALUES
(1, 1, 10),
(2, 2, 20),
(3, 1, 50);

-- Exibir tabela produtos depois dos INSERTS na tabela itens_venda e o efeito do TRIGGER
SELECT * FROM produtos;

-- Exibir tabela itens_venda
SELECT * FROM itens_venda;

-- Exibir a tabela vendas para mostrar as duas vendas registradas
SELECT * FROM vendas;

/* Exibir o bloqueio do TRIGGER ao tentar vender uma quantidade do produto 
maior do que a existente no estoque (tabela produtos) */
INSERT INTO itens_venda (id_venda, id_produto, quantidade) VALUES
(3, 1, 500);

/* Exibir o bloqueio do TRIGGER ao tentar realizar uma venda de quantidade 0 do produto */
INSERT INTO itens_venda (id_venda, id_produto, quantidade) VALUES
(3, 1, 0);

-- FIM DA EXECUÇÃO

-- OPCIONAL: VIEW para exibir as vendas realizadas com mais detalhes.
CREATE VIEW vw_vendas_realizadas AS
SELECT IV.id_item_venda AS 'Id', P.nome AS 'Produto', IV.quantidade AS 'Quantidade Vendida',
V.data_venda AS 'Data' FROM itens_venda IV
INNER JOIN produtos P ON P.id_produto = IV.id_produto
INNER JOIN vendas V ON V.id_venda = IV.id_venda;

-- Executar VIEW para exibir as vendas realizadas de forma mais organizada.
SELECT * FROM vw_vendas_realizadas;

-- DROP DATABASE para reiniciar caso necessário.
DROP DATABASE atividade_triggerii;
