/* Exercício 3:
 Em um sistema de recursos humanos, crie um trigger que, ao inserir um novo funcionário na tabela "funcionarios", 
 verifique se a data de admissão é maior que a data atual. Caso contrário, o trigger deve exibir uma mensagem de erro 
 informando que a data de admissão deve ser maior que a data atual.
 */

CREATE DATABASE atividade_triggerii;

USE atividade_triggerii;

-- Criar tabela funcionarios
CREATE TABLE funcionarios (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(255) NOT NULL,
cargo VARCHAR(100) NOT NULL,
data_admissao DATE NOT NULL
);

/* Criar trigger que não permite que novos funcionários sejam admitidos caso a data de admissão no registro
seja igual ou menor que a data atual.
*/
DELIMITER //

CREATE TRIGGER tg_admissao_funcionario
BEFORE INSERT ON funcionarios
FOR EACH ROW
BEGIN
	IF(NEW.data_admissao <= CURDATE()) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Negado. Data de admissão deve ser maior que a data atual.';
    END IF;
END//

DELIMITER ;

-- Inserir novo funcionário na tabela com a data de admissão correta (data de admissão maior que a data atual)
INSERT INTO funcionarios (nome, cargo, data_admissao) VALUES
('Silvonei Certo', 'Desenvolvedor Back-End Júnior', '2023-12-23');

-- Exibir tabela funcionarios antes do TRIGGER
SELECT * FROM funcionarios;

/* Exibir funcionamento de trigger ao tentar inserir funcionario com a data de admissão incorreta 
(data de admissão menor que a data atual). O registro não será inserido.
*/
INSERT INTO funcionarios (nome, cargo, data_admissao) VALUES
('Márcio Errado', 'Programador HTML', CURDATE()); 

-- Exibir tabela funcionarios após o TRIGGER, registro com data de admissão incorreta não será inserido.
SELECT * FROM funcionarios;

DROP DATABASE atividade_triggerii;
