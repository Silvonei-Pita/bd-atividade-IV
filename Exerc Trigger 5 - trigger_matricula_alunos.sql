/*
Exercício 5:

Você está desenvolvendo um sistema de gerenciamento de alunos para uma escola. O sistema possui as seguintes tabelas:

Tabela "alunos":
- Colunas: id_aluno (chave primária), nome (varchar), data_nascimento (date), serie (int)

Tabela "matriculas":
- Colunas: id_matricula (chave primária), id_aluno (chave estrangeira referenciando a tabela "alunos"), }
data_matricula (date), status (varchar)

Crie um trigger que, ao inserir uma nova matrícula na tabela "matriculas", 
verifique se o aluno correspondente possui idade suficiente para a série em que está sendo matriculado. 
Se não tiver, retorne um erro informando que o aluno não atende aos requisitos de idade para a série.

*/

CREATE DATABASE atividade_triggerii;

USE atividade_triggerii;

-- Criar tabela alunos
CREATE TABLE alunos(
id_aluno INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(255) NOT NULL,
data_nascimento DATE NOT NULL,
serie INT NOT NULL
);

-- Criar tabela matrículas
CREATE TABLE matriculas (
id_matricula INT PRIMARY KEY AUTO_INCREMENT,
id_aluno INT NOT NULL,
data_matricula DATE NOT NULL,
status VARCHAR(100) NOT NULL,
FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno)
);

-- Inserir dois alunos (crianças) que ainda não se matricularam em nenhuma escola
INSERT INTO alunos (nome, data_nascimento, serie) VALUES 
('Vanessa', '2019-11-19', 0),
('Leandro', '2021-12-20', 0);


/*
Criar Trigger que não permite matrícula de alunos que não possuam 4 anos ou mais. Além disso, alunos matriculados
são atribuídos à série '1'.
*/
DELIMITER //

CREATE TRIGGER tg_valida_matricula
BEFORE INSERT ON matriculas
FOR EACH ROW
BEGIN
	declare idade int;
	SELECT (YEAR(CURDATE()) - YEAR(data_nascimento)) into idade FROM alunos WHERE id_aluno = NEW.id_aluno;
	IF idade < 4 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ação negada. Aluno não possui idade mínima (4) para se matricular.';
	ELSE
		UPDATE alunos
        SET serie = 1 WHERE id_aluno = NEW.id_aluno;
	END IF;
END//

DELIMITER ;

-- Matricular aluno de id 1 (sucesso)
INSERT INTO matriculas (id_aluno, data_matricula, status) VALUES
(1, CURDATE(), 'Aprovado');

-- Tentativa de matricular aluno de id 2 (não irá funcionar.)
INSERT INTO matriculas (id_aluno, data_matricula, status) VALUES
(2, CURDATE(), 'Negada');

-- Exibir tabela alunos
SELECT * FROM alunos;

-- Reiniciar a tabela caso seja necessário
DROP DATABASE atividade_triggerii;