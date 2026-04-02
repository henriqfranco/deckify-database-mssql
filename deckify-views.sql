USE FlashcardApp;
GO

-- ================================================
-- vw_DeckSummary
-- Objetivo:
-- Retornar um resumo de cada deck com dados do dono
-- e a quantidade total de cards por deck.
--
-- Como funciona:
-- 1) Faz INNER JOIN com Users para identificar o dono do deck.
-- 2) Faz LEFT JOIN com Cards para incluir decks sem cards.
-- 3) Usa COUNT(c.CardID) + GROUP BY para consolidar o total.
-- ================================================
CREATE OR ALTER VIEW vw_DeckSummary
AS
    SELECT
        d.DeckID,
        d.Title         AS DeckTitle,
        d.Description,
        u.UserID,
        u.Username,
        COUNT(c.CardID) AS TotalCards,
        d.CreatedAt
    FROM Decks d
        INNER JOIN Users u ON u.UserID = d.UserID
        LEFT JOIN Cards c ON c.DeckID = d.DeckID
    GROUP BY
    d.DeckID, d.Title, d.Description,
    u.UserID, u.Username, d.CreatedAt;
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

-------------------------------------------

-- ================================================
-- vw_CardDetails
-- Objetivo:
-- Retornar os detalhes de cada card junto com
-- informacoes do deck e do usuario dono.
--
-- Como funciona:
-- 1) Parte de Cards (cada linha representa um card).
-- 2) Usa INNER JOIN com Decks para trazer o titulo do deck.
-- 3) Usa INNER JOIN com Users para identificar o dono.
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
        c.CreatedAt
    FROM Cards c
        INNER JOIN Decks d ON d.DeckID = c.DeckID
        INNER JOIN Users u ON u.UserID = d.UserID;
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