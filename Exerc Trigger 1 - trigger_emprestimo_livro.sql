/* Exercício 1:

Você está desenvolvendo um sistema de gerenciamento de biblioteca. O sistema possui as seguintes tabelas:

Tabela "livros":
- Colunas: id_livro (chave primária), título (varchar), autor (varchar), quantidade_estoque (int)

Tabela "emprestimos":
- Colunas: id_emprestimo (chave primária), id_livro (chave estrangeira referenciando a tabela "livros"), data_emprestimo (datetime), data_devolucao (datetime)

Crie um trigger que, ao inserir um novo empréstimo na tabela "emprestimos", 
atualize automaticamente a quantidade de estoque do livro correspondente na tabela "livros", subtraindo 1.

*/

CREATE DATABASE atividade_triggerII;

USE atividade_triggerII;

-- Criar tabela de livros
CREATE TABLE livros (
id_livro INT AUTO_INCREMENT PRIMARY KEY,
titulo VARCHAR(255) NOT NULL,
autor VARCHAR(255) NOT NULL,
quantidade_estoque INT NOT NULL
);

-- Criar tabela de empréstimos
CREATE TABLE emprestimos (
id_emprestimo INT AUTO_INCREMENT PRIMARY KEY,
id_livro INT NOT NULL,
data_emprestimo DATETIME NOT NULL,
data_devolucao DATETIME NOT NULL,
FOREIGN KEY(id_livro) REFERENCES livros(id_livro)
);

-- Inserir dois livros na tabela livros
INSERT INTO livros (titulo, autor, quantidade_estoque) VALUES
('A Biblioteca da Meia-Noite', 'Matt Haig', 50),
('Pai Rico e Pai Pobre', 'Robert T.', 3);

/* Criar Trigger que a cada novo empréstimo, subtraia em 1 de quantidade em estoque do livro que foi emprestado.
Trigger também bloqueará tentativa de empréstimo de livro que está fora do estoque.
*/
DELIMITER //
CREATE TRIGGER tg_emprestimo_livro
BEFORE INSERT ON emprestimos
FOR EACH ROW
BEGIN
	DECLARE qtd_estoque_atual int;
	SELECT quantidade_estoque INTO qtd_estoque_atual FROM livros WHERE id_livro = NEW.id_livro;
    IF qtd_estoque_atual <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ação negada. produto fora do estoque.';
	ELSE
		UPDATE livros
		SET quantidade_estoque = quantidade_estoque - 1 WHERE id_livro = NEW.id_livro;
    END IF;
END//
DELIMITER ;

/* Exibir tabela livros antes dos empréstimos e do Trigger
50 livros de id 1;
3 livros de id 2 */
SELECT * FROM livros;

/* Realização de quatro empréstimos: 
3 livros de id 1;
3 livros de id 2 */
INSERT INTO emprestimos (id_livro, data_emprestimo, data_devolucao) VALUES
(1, '2023-12-18 19:00:50', '2024-04-10 16:00:50'), 
(1, '2023-11-17 18:00:50', '2024-03-10 17:00:50'),
(1, '2023-10-16 17:00:50', '2024-02-10 18:00:50'), 
(2, '2023-09-15 16:00:50', '2024-01-10 19:00:50'),
(2, '2023-08-14 15:00:50', '2023-12-10 20:00:50'),
(2, '2023-07-13 14:00:50', '2023-11-10 21:00:50');

/* Exibir tabela livros após os empréstimos e o efeito do Trigger. Sobraram:
47 livros do id 1;
0 livro do id 2 */
SELECT * FROM livros;

/* OPCIONAL: Demonstrar bloqueio do TRIGGER ao tentar realizar empréstimo do livro de id 2 após o 
estoque desse livro ter esgotado.
*/
INSERT INTO emprestimos (id_livro, data_emprestimo, data_devolucao) VALUES
(2, '2023-06-12 15:00:50', '2023-10-10 22:00:50');


-- Excluir banco de dados para reiniciar SCRIPT
DROP DATABASE atividade_triggerii;