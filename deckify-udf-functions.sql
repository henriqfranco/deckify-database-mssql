USE FlashcardApp;
GO

-- ================================================
-- fn_GetDeckInsights (Table-Valued Function)
-- Retorna uma visao consolidada dos decks, incluindo:
-- - dados do dono
-- - total de cards
-- - total de downloads
-- - ultimo download
-- - indicador se um usuario especifico ja baixou o deck
--
-- Parametros:
-- @DeckID: filtra um deck especifico (NULL = todos)
-- @UserID: calcula HasUserDownloaded para esse usuario (NULL = sempre 0)
--
-- Uso:
-- SELECT * FROM dbo.fn_GetDeckInsights(NULL, NULL)
-- SELECT * FROM dbo.fn_GetDeckInsights(3, NULL)
-- SELECT * FROM dbo.fn_GetDeckInsights(NULL, 1)
-- ================================================

CREATE OR ALTER FUNCTION dbo.fn_GetDeckInsights
(
    @DeckID INT = NULL,
    @UserID INT = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT
    d.DeckID,
    d.Title                   AS DeckTitle,
    d.Description,
    d.UserID                  AS DeckOwnerUserID,
    u.Username                AS DeckOwnerUsername,
    ISNULL(card_stats.TotalCards, 0)         AS TotalCards,
    ISNULL(download_stats.TotalDownloads, 0) AS TotalDownloads,
    download_stats.LastDownloadedAt,
    CAST(
            CASE
                WHEN @UserID IS NULL THEN 0
                WHEN EXISTS (
                    SELECT 1
    FROM DeckDownloads dd_user
    WHERE dd_user.DeckID = d.DeckID
        AND dd_user.UserID = @UserID
                ) THEN 1
                ELSE 0
            END AS BIT
        ) AS HasUserDownloaded,
    d.CreatedAt,
    d.UpdatedAt
FROM Decks d
    INNER JOIN Users u ON u.UserID = d.UserID
    LEFT JOIN (
            SELECT
        DeckID,
        COUNT(*) AS TotalCards
    FROM Cards
    GROUP BY DeckID
        ) card_stats ON card_stats.DeckID = d.DeckID
    LEFT JOIN (
            SELECT
        DeckID,
        COUNT(*)          AS TotalDownloads,
        MAX(DownloadedAt) AS LastDownloadedAt
    FROM DeckDownloads
    GROUP BY DeckID
        ) download_stats ON download_stats.DeckID = d.DeckID
WHERE @DeckID IS NULL OR d.DeckID = @DeckID
);
GO

-- Exibe insights de todos os decks
SELECT *
FROM dbo.fn_GetDeckInsights(NULL, NULL);

-- Exibe insights de um deck especifico
SELECT *
FROM dbo.fn_GetDeckInsights(3, NULL);

-- Exibe insights incluindo o indicador de download para um usuario
SELECT *
FROM dbo.fn_GetDeckInsights(NULL, 1);