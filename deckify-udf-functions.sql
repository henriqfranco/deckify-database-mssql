USE FlashcardApp;
GO

-- ================================================
-- fn_GetCardCount
-- Retorna a quantidade total de cards de um deck.
--
-- Como funciona:
-- 1) Recebe @DeckID como entrada.
-- 2) Conta os registros da tabela Cards com esse DeckID.
-- 3) Retorna o total como INT.
--
-- Uso: SELECT dbo.fn_GetCardCount(1)
-- ================================================

CREATE OR ALTER FUNCTION dbo.fn_GetCardCount
(
    @DeckID INT
)
RETURNS INT
AS
BEGIN
    -- Agregacao simples para obter o total de cards do deck informado.
    RETURN (
        SELECT COUNT(*)
    FROM Cards
    WHERE DeckID = @DeckID
    );
END
GO

-- ================================================
-- fn_GetDeckCount
-- Retorna a quantidade total de decks de um usuario.
--
-- Como funciona:
-- 1) Recebe @UserID como entrada.
-- 2) Conta os registros da tabela Decks desse usuario.
-- 3) Retorna o total como INT.
--
-- Uso: SELECT dbo.fn_GetDeckCount(1)
-- ================================================

CREATE OR ALTER FUNCTION dbo.fn_GetDeckCount
(
    @UserID INT
)
RETURNS INT
AS
BEGIN
    -- Agregacao simples para obter o total de decks do usuario informado.
    RETURN (
        SELECT COUNT(*)
    FROM Decks
    WHERE UserID = @UserID
    );
END
GO

-- ================================================
-- fn_GetCardsByDeck (Table-Valued Function)
-- Retorna todos os cards de um deck especifico.
-- E util para filtros, joins e CROSS APPLY.
--
-- Como funciona:
-- 1) Recebe @DeckID como parametro.
-- 2) Retorna uma tabela com CardID, Front, Back e CreatedAt.
-- 3) Inclui apenas linhas cujo DeckID corresponda ao parametro.
--
-- Uso: SELECT * FROM dbo.fn_GetCardsByDeck(2)
-- ================================================

CREATE OR ALTER FUNCTION dbo.fn_GetCardsByDeck
(
    @DeckID INT
)
RETURNS TABLE
AS
RETURN
(
    -- TVF inline: o resultado desta consulta e o retorno da funcao.
    SELECT
    CardID,
    Front,
    Back,
    CreatedAt
FROM Cards
WHERE DeckID = @DeckID
);
GO

-- ================================================
-- fn_SearchCards (Table-Valued Function)
-- Busca cards por palavra-chave em Front e Back,
-- com filtro opcional por deck.
--
-- Como funciona:
-- 1) Recebe @Keyword para pesquisa textual (LIKE).
-- 2) Faz JOIN com Decks para retornar DeckID e DeckTitle.
-- 3) Se @DeckID for NULL, busca em todos os decks.
-- 4) Se @DeckID tiver valor, limita a busca ao deck informado.
--
-- Uso: SELECT * FROM dbo.fn_SearchCards('closure', NULL)
--      SELECT * FROM dbo.fn_SearchCards('ls', 1)
-- ================================================

CREATE OR ALTER FUNCTION dbo.fn_SearchCards
(
    @Keyword NVARCHAR(200),
    @DeckID  INT = NULL
)
RETURNS TABLE
AS
RETURN
(
    -- TVF inline com busca textual e filtro opcional por deck.
    SELECT
    c.CardID,
    c.Front,
    c.Back,
    d.DeckID,
    d.Title AS DeckTitle
FROM Cards c
    INNER JOIN Decks d ON d.DeckID = c.DeckID
WHERE
        (c.Front LIKE '%' + @Keyword + '%' OR c.Back LIKE '%' + @Keyword + '%')
    AND (@DeckID IS NULL OR c.DeckID = @DeckID)
);
GO

-- Exibe cada deck com a contagem de cards calculada pela UDF escalar
SELECT DeckID, Title, dbo.fn_GetCardCount(DeckID) AS TotalCards
FROM Decks
WHERE UserID = 1;

-- Busca global em todos os decks (passando @DeckID = NULL)
SELECT *
FROM dbo.fn_SearchCards('hoisting', NULL);

-- Busca limitada a um deck especifico
SELECT *
FROM dbo.fn_SearchCards('ls', 1);

-- Exemplo de combinacao da TVF com Decks usando CROSS APPLY
SELECT d.Title, c.Front, c.Back
FROM Decks d
CROSS APPLY dbo.fn_GetCardsByDeck(d.DeckID) c
WHERE d.UserID = 1;