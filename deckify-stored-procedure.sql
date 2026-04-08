USE FlashcardApp;
GO

-- ================================================
-- sp_DownloadDeck
-- Registra o download de um deck da comunidade
-- e retorna os dados completos do deck + cards.
--
-- Comportamento:
-- 1) Valida usuario e deck.
-- 2) Impede download do proprio deck.
-- 3) Se ja existir download (UserID + DeckID), atualiza DownloadedAt.
-- 4) Se nao existir, cria o registro em DeckDownloads.
-- 5) Retorna 3 result sets:
--    a) status da operacao
--    b) metadados do deck
--    c) lista de cards do deck
-- ================================================

CREATE OR ALTER PROCEDURE sp_DownloadDeck
    @UserID INT,
    @DeckID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
    FROM Users
    WHERE UserID = @UserID
    )
    BEGIN
        RAISERROR('User not found.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
    FROM Decks
    WHERE DeckID = @DeckID
    )
    BEGIN
        RAISERROR('Deck not found.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
    FROM Decks
    WHERE DeckID = @DeckID
        AND UserID = @UserID
    )
    BEGIN
        RAISERROR('You cannot download your own deck.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
    FROM DeckDownloads
    WHERE UserID = @UserID
        AND DeckID = @DeckID
    )
    BEGIN
        UPDATE DeckDownloads
        SET DownloadedAt = GETDATE()
        WHERE UserID = @UserID
            AND DeckID = @DeckID;

        SELECT
            CAST(0 AS BIT) AS IsFirstDownload,
            'Download timestamp refreshed.' AS [Message];
    END
    ELSE
    BEGIN
        INSERT INTO DeckDownloads
            (UserID, DeckID, DownloadedAt)
        VALUES
            (@UserID, @DeckID, GETDATE());

        SELECT
            CAST(1 AS BIT) AS IsFirstDownload,
            'Deck downloaded successfully.' AS [Message];
    END

    SELECT
        d.DeckID,
        d.Title,
        d.Description,
        d.UserID                    AS DeckOwnerUserID,
        owner_u.Username            AS DeckOwnerUsername,
        dd.UserID                   AS DownloadedByUserID,
        downloader_u.Username       AS DownloadedByUsername,
        dd.DownloadedAt,
        d.CreatedAt,
        d.UpdatedAt
    FROM Decks d
        INNER JOIN Users owner_u ON owner_u.UserID = d.UserID
        INNER JOIN DeckDownloads dd ON dd.DeckID = d.DeckID AND dd.UserID = @UserID
        INNER JOIN Users downloader_u ON downloader_u.UserID = dd.UserID
    WHERE d.DeckID = @DeckID;

    SELECT
        c.CardID,
        c.DeckID,
        c.Front,
        c.Back,
        c.CreatedAt,
        c.UpdatedAt
    FROM Cards c
    WHERE c.DeckID = @DeckID
    ORDER BY c.CardID;
END
GO

-- Exemplo de uso
EXEC sp_DownloadDeck @UserID = 1, @DeckID = 3;