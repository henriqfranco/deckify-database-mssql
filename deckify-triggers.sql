USE FlashcardApp;
GO

-- ================================================
-- trg_DeckDownloads_EnforceAndTouchDeck
-- Trigger com regra de negocio + auditoria.
--
-- Objetivo:
-- 1) Impedir que o dono do deck registre download do proprio deck.
-- 2) Atualizar Decks.UpdatedAt sempre que houver mudanca em DeckDownloads.
-- 3) Registrar log da alteracao em DeckDownloads.
--
-- Como funciona:
-- 1) Dispara em INSERT, UPDATE e DELETE de DeckDownloads.
-- 2) Valida a regra de negocio com base na pseudo-tabela inserted.
-- 3) Toca UpdatedAt dos decks afetados (inserted/deleted).
-- 4) Persiste detalhes da mudanca na tabela Logs.
-- ================================================

CREATE OR ALTER TRIGGER trg_DeckDownloads_EnforceAndTouchDeck
ON DeckDownloads
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Evita mensagens de "N rows affected" durante a execucao.
    SET NOCOUNT ON;

    DECLARE @InsertedCount INT = (SELECT COUNT(*)
    FROM inserted);
    DECLARE @DeletedCount INT = (SELECT COUNT(*)
    FROM deleted);
    DECLARE @OperationType NVARCHAR(10) =
        CASE
            WHEN @InsertedCount > 0 AND @DeletedCount > 0 THEN 'UPDATE'
            WHEN @InsertedCount > 0 THEN 'INSERT'
            ELSE 'DELETE'
        END;
    DECLARE @AffectedRows INT =
        CASE
            WHEN @OperationType = 'DELETE' THEN @DeletedCount
            ELSE @InsertedCount
        END;

    -- Regra: o dono nao pode baixar o proprio deck.
    IF EXISTS (
        SELECT 1
    FROM inserted i
        INNER JOIN Decks d ON d.DeckID = i.DeckID
    WHERE d.UserID = i.UserID
    )
    BEGIN
        RAISERROR('Deck owner cannot download their own deck.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Atualiza timestamp de decks afetados por insert/update/delete.
    ;
    WITH
        ChangedDecks
        AS
        (
                            SELECT DeckID
                FROM inserted
            UNION
                SELECT DeckID
                FROM deleted
        )
    UPDATE d
    SET UpdatedAt = GETDATE()
    FROM Decks d
        INNER JOIN ChangedDecks cd ON cd.DeckID = d.DeckID;

    INSERT INTO Logs
        (TableName, OperationType, AffectedRows, DetailsJson)
    VALUES
        (
            'DeckDownloads',
            @OperationType,
            @AffectedRows,
            (
                SELECT
                (SELECT *
                FROM inserted
                FOR JSON PATH) AS inserted_rows,
                (SELECT *
                FROM deleted
                FOR JSON PATH) AS deleted_rows
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
        );
END
GO

-- ================================================
-- trg_Users_LogChanges
-- Audita INSERT/UPDATE/DELETE na tabela Users.
-- ================================================
CREATE OR ALTER TRIGGER trg_Users_LogChanges
ON Users
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertedCount INT = (SELECT COUNT(*)
    FROM inserted);
    DECLARE @DeletedCount INT = (SELECT COUNT(*)
    FROM deleted);
    DECLARE @OperationType NVARCHAR(10) =
        CASE
            WHEN @InsertedCount > 0 AND @DeletedCount > 0 THEN 'UPDATE'
            WHEN @InsertedCount > 0 THEN 'INSERT'
            ELSE 'DELETE'
        END;
    DECLARE @AffectedRows INT =
        CASE
            WHEN @OperationType = 'DELETE' THEN @DeletedCount
            ELSE @InsertedCount
        END;

    INSERT INTO Logs
        (TableName, OperationType, AffectedRows, DetailsJson)
    VALUES
        (
            'Users',
            @OperationType,
            @AffectedRows,
            (
                SELECT
                (SELECT *
                FROM inserted
                FOR JSON PATH) AS inserted_rows,
                (SELECT *
                FROM deleted
                FOR JSON PATH) AS deleted_rows
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
        );
END
GO

-- ================================================
-- trg_Decks_LogChanges
-- Audita INSERT/UPDATE/DELETE na tabela Decks.
-- ================================================
CREATE OR ALTER TRIGGER trg_Decks_LogChanges
ON Decks
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertedCount INT = (SELECT COUNT(*)
    FROM inserted);
    DECLARE @DeletedCount INT = (SELECT COUNT(*)
    FROM deleted);
    DECLARE @OperationType NVARCHAR(10) =
        CASE
            WHEN @InsertedCount > 0 AND @DeletedCount > 0 THEN 'UPDATE'
            WHEN @InsertedCount > 0 THEN 'INSERT'
            ELSE 'DELETE'
        END;
    DECLARE @AffectedRows INT =
        CASE
            WHEN @OperationType = 'DELETE' THEN @DeletedCount
            ELSE @InsertedCount
        END;

    INSERT INTO Logs
        (TableName, OperationType, AffectedRows, DetailsJson)
    VALUES
        (
            'Decks',
            @OperationType,
            @AffectedRows,
            (
                SELECT
                (SELECT *
                FROM inserted
                FOR JSON PATH) AS inserted_rows,
                (SELECT *
                FROM deleted
                FOR JSON PATH) AS deleted_rows
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
        );
END
GO

-- ================================================
-- trg_Cards_LogChanges
-- Audita INSERT/UPDATE/DELETE na tabela Cards.
-- ================================================
CREATE OR ALTER TRIGGER trg_Cards_LogChanges
ON Cards
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertedCount INT = (SELECT COUNT(*)
    FROM inserted);
    DECLARE @DeletedCount INT = (SELECT COUNT(*)
    FROM deleted);
    DECLARE @OperationType NVARCHAR(10) =
        CASE
            WHEN @InsertedCount > 0 AND @DeletedCount > 0 THEN 'UPDATE'
            WHEN @InsertedCount > 0 THEN 'INSERT'
            ELSE 'DELETE'
        END;
    DECLARE @AffectedRows INT =
        CASE
            WHEN @OperationType = 'DELETE' THEN @DeletedCount
            ELSE @InsertedCount
        END;

    INSERT INTO Logs
        (TableName, OperationType, AffectedRows, DetailsJson)
    VALUES
        (
            'Cards',
            @OperationType,
            @AffectedRows,
            (
                SELECT
                (SELECT *
                FROM inserted
                FOR JSON PATH) AS inserted_rows,
                (SELECT *
                FROM deleted
                FOR JSON PATH) AS deleted_rows
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
        );
END
GO