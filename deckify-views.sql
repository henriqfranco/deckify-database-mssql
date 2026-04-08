USE FlashcardApp;
GO

-- ================================================
-- vw_DeckSummary
-- Objetivo:
-- Retornar um resumo de cada deck com dados do dono
-- com metricas de cards e downloads da comunidade.
--
-- Como funciona:
-- 1) Faz INNER JOIN com Users para identificar o dono do deck.
-- 2) Faz LEFT JOIN em subconsulta de Cards agregada por DeckID.
-- 3) Faz LEFT JOIN em subconsulta de DeckDownloads agregada por DeckID.
-- 4) Usa ISNULL para retornar zero quando nao houver registros.
-- ================================================
CREATE OR ALTER VIEW vw_DeckSummary
AS
    SELECT
        d.DeckID,
        d.Title         AS DeckTitle,
        d.Description,
        u.UserID,
        u.Username,
        ISNULL(card_stats.TotalCards, 0)             AS TotalCards,
        ISNULL(download_stats.TotalDownloads, 0)     AS TotalDownloads,
        download_stats.LastDownloadedAt,
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
        ) download_stats ON download_stats.DeckID = d.DeckID;
GO

-- 1. Exibe todas as linhas retornadas pela view
SELECT *
FROM vw_DeckSummary;

-- 2. Lista todos os decks de um usuario especifico
SELECT *
FROM vw_DeckSummary
WHERE UserID = 1;

-- 3. Mostra apenas decks que possuem ao menos 1 card
SELECT *
FROM vw_DeckSummary
WHERE TotalCards > 0;

-- 4. Mostra os decks mais baixados pela comunidade
SELECT *
FROM vw_DeckSummary
ORDER BY TotalDownloads DESC, DeckID ASC;

-------------------------------------------

-- ================================================
-- vw_CardDetails
-- Objetivo:
-- Retornar os detalhes de cada card junto com
-- informacoes do deck, dono e popularidade do deck.
--
-- Como funciona:
-- 1) Parte de Cards (cada linha representa um card).
-- 2) Usa INNER JOIN com Decks para trazer o titulo do deck.
-- 3) Usa INNER JOIN com Users para identificar o dono.
-- 4) Usa LEFT JOIN em agregacao de downloads por deck.
-- ================================================
CREATE OR ALTER VIEW vw_CardDetails
AS
    SELECT
        c.CardID,
        c.Front,
        c.Back,
        d.DeckID,
        d.Title   AS DeckTitle,
        u.UserID,
        u.Username,
        c.CreatedAt,
        ISNULL(download_stats.TotalDownloads, 0) AS DeckTotalDownloads
    FROM Cards c
        INNER JOIN Decks d ON d.DeckID = c.DeckID
        INNER JOIN Users u ON u.UserID = d.UserID
        LEFT JOIN (
            SELECT
            DeckID,
            COUNT(*) AS TotalDownloads
        FROM DeckDownloads
        GROUP BY DeckID
        ) download_stats ON download_stats.DeckID = d.DeckID;
GO

-- 1. Exibe todas as linhas retornadas pela view
SELECT *
FROM vw_CardDetails;

-- 2. Lista todos os cards de um deck especifico
SELECT *
FROM vw_CardDetails
WHERE DeckID = 2;

-- 3. Lista todos os cards pertencentes a um usuario
SELECT *
FROM vw_CardDetails
WHERE UserID = 1;

-- 4. Busca cards por palavra-chave no Front ou Back
SELECT *
FROM vw_CardDetails
WHERE Front LIKE '%closure%' OR Back LIKE '%closure%';

-------------------------------------------

-- ================================================
-- vw_DeckDownloadDetails
-- Objetivo:
-- Retornar cada evento de download de deck com
-- dados de quem baixou e de quem e o dono do deck.
--
-- Como funciona:
-- 1) Parte de DeckDownloads (um registro por download).
-- 2) Junta com Decks para obter dados do deck.
-- 3) Junta duas vezes com Users: dono e usuario que baixou.
-- ================================================
CREATE OR ALTER VIEW vw_DeckDownloadDetails
AS
    SELECT
        dd.DownloadID,
        dd.DeckID,
        d.Title                  AS DeckTitle,
        d.UserID                 AS DeckOwnerUserID,
        owner_u.Username         AS DeckOwnerUsername,
        dd.UserID                AS DownloadedByUserID,
        downloader_u.Username    AS DownloadedByUsername,
        dd.DownloadedAt
    FROM DeckDownloads dd
        INNER JOIN Decks d ON d.DeckID = dd.DeckID
        INNER JOIN Users owner_u ON owner_u.UserID = d.UserID
        INNER JOIN Users downloader_u ON downloader_u.UserID = dd.UserID;
GO

-- 1. Exibe o historico completo de downloads
SELECT *
FROM vw_DeckDownloadDetails;

-- 2. Mostra downloads de um deck especifico
SELECT *
FROM vw_DeckDownloadDetails
WHERE DeckID = 1;

-- 3. Mostra downloads feitos por um usuario especifico
SELECT *
FROM vw_DeckDownloadDetails
WHERE DownloadedByUserID = 1;