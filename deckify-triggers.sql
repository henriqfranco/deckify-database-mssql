USE FlashcardApp;
GO

-- ================================================
-- trg_Cards_UpdatedAt
-- Atualiza automaticamente o campo UpdatedAt em Cards
-- sempre que um registro sofrer UPDATE.
--
-- Como funciona:
-- 1) O trigger dispara apos UPDATE na tabela Cards.
-- 2) A pseudo-tabela inserted contem os CardID afetados.
-- 3) O UPDATE final atualiza somente as linhas alteradas.
-- ================================================

CREATE OR ALTER TRIGGER trg_Cards_UpdatedAt
ON Cards
AFTER UPDATE
AS
BEGIN
    -- Evita mensagens de "N rows affected" durante a execucao.
    SET NOCOUNT ON;

    -- Define a data/hora atual para os cards atualizados nesta operacao.
    UPDATE Cards
    SET UpdatedAt = GETDATE()
    FROM Cards c
        INNER JOIN inserted i ON i.CardID = c.CardID;
END
GO

-- ================================================
-- trg_Decks_UpdatedAt
-- Atualiza automaticamente o campo UpdatedAt em Decks
-- sempre que um registro sofrer UPDATE.
--
-- Como funciona:
-- 1) O trigger dispara apos UPDATE na tabela Decks.
-- 2) A pseudo-tabela inserted contem os DeckID afetados.
-- 3) O UPDATE final atualiza somente as linhas alteradas.
-- ================================================

CREATE OR ALTER TRIGGER trg_Decks_UpdatedAt
ON Decks
AFTER UPDATE
AS
BEGIN
    -- Evita mensagens de "N rows affected" durante a execucao.
    SET NOCOUNT ON;

    -- Define a data/hora atual para os decks atualizados nesta operacao.
    UPDATE Decks
    SET UpdatedAt = GETDATE()
    FROM Decks d
        INNER JOIN inserted i ON i.DeckID = d.DeckID;
END
GO

-- ================================================
-- trg_Decks_PreventDeleteWithCards
-- Bloqueia a exclusao de um deck que ainda possui cards.
-- Hoje o FK_Cards_Decks esta com ON DELETE CASCADE,
-- entao a exclusao automatica ja e tratada pelo FK.
-- Este trigger fica como exemplo de regra manual.
--
-- Como funcionaria:
-- 1) Em tentativa de DELETE, verifica se existem cards vinculados.
-- 2) Se existir, levanta erro e cancela a transacao.
-- 3) Se nao existir, permite excluir os decks da pseudo-tabela deleted.
--
-- OBS: Para usar este trigger, remova antes o
-- ON DELETE CASCADE da FK_Cards_Decks.
-- ================================================

-- CREATE OR ALTER TRIGGER trg_Decks_PreventDeleteWithCards
-- ON Decks
-- INSTEAD OF DELETE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     IF EXISTS (
--         SELECT 1 FROM Cards c
--         INNER JOIN deleted d ON d.DeckID = c.DeckID
--     )
--     BEGIN
--         RAISERROR('Cannot delete a deck that still has cards. Remove the cards first.', 16, 1);
--         ROLLBACK TRANSACTION;
--         RETURN;
--     END
-- 
--     DELETE FROM Decks WHERE DeckID IN (SELECT DeckID FROM deleted);
-- END
-- GO