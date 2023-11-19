/* Exercício 2:

Você está desenvolvendo um sistema de gerenciamento de finanças pessoais. O sistema possui as seguintes tabelas:

Tabela "contas":
- Colunas: id_conta (chave primária), nome (varchar), saldo (decimal)

Tabela "transacoes":
- Colunas: id_transacao (chave primária), id_conta (chave estrangeira referenciando a tabela "contas"), 
tipo (varchar), valor (decimal)

Crie um trigger que, ao inserir uma nova transação na tabela "transacoes", 
atualize automaticamente o saldo da conta correspondente na tabela "contas". 
Se o tipo da transação for "entrada", adicione o valor ao saldo. 
Se o tipo for "saída", subtraia o valor do saldo.

*/

CREATE DATABASE atividade_triggerII;

USE atividade_triggerII;

-- INÍCIO DA EXECUÇÃO

-- Criar tabela contas
CREATE TABLE contas (
id_conta int primary key auto_increment,
nome varchar(255) not null,
saldo decimal(10,2) not null
);

-- Criar tabela de transações
CREATE TABLE transacoes (
id_transacao int primary key auto_increment,
id_conta int,
tipo varchar(100) not null,
valor decimal(10,2) not null,
foreign key(id_conta) references contas(id_conta)
);

/* Criar trigger que a cada nova transação realizada atualize a o saldo da conta correspondente. Além disso, trigger
não permite que transações que não sejam do tipo 'entrada' ou do tipo 'saida' sejam inseridas no banco de dados */
 DELIMITER //

CREATE TRIGGER trigger_transacoes_conta
BEFORE INSERT ON transacoes
FOR EACH ROW
BEGIN
	IF (new.tipo = 'entrada' OR new.tipo = 'saida') THEN
		UPDATE contas
		SET saldo = CASE 
		WHEN new.tipo = 'entrada' THEN saldo + NEW.valor 
		WHEN new.tipo = 'saida' THEN saldo - NEW.valor END WHERE id_conta = NEW.id_conta;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro. Tipo de transação inválido.'; 
    END IF;
END//

 DELIMITER ;
 
 -- Inserir duas contas bancárias na tabela contas
INSERT INTO contas (id_conta, nome, saldo) VALUES
(1, 'Silvonei', 1200),
(2, 'Marcelo', 2400);

-- Exibir tabela contas antes das transações e do TRIGGER
SELECT * FROM contas;

-- Efetuar duas transações. Essas duas transações farão que o saldo das contas de id 1 e 2 fiquem iguais.
INSERT INTO transacoes (id_conta, tipo, valor) VALUES
(1, 'entrada', 800),
(2, 'saida', 400);

-- Exibir tabela contas depois das transações e do efeito do TRIGGER
SELECT * FROM contas;

-- Exibir tabela das transações
SELECT * FROM transacoes;

-- FIM DA EXECUÇÃO

-- OPCIONAL - TESTE: Inserir transações inválidas

-- Tentar inserir transação inválida (que não seja do tipo 'entrada' ou do tipo 'saida')
INSERT INTO transacoes (id_conta, tipo, valor) VALUES
(1, 'teste', 15000);

-- Verificar tabela transações para ver se a transação inválida foi realizada (ela não será.)
SELECT * FROM transacoes;

-- Verificar tabela de contas para ver se o saldo da conta de id 1 foi alterado (não será.)
SELECT * FROM contas;

-- Excluir o banco de dados para reiniciar tudo.
DROP DATABASE atividade_triggerii;
