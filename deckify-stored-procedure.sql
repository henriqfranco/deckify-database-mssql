-- ================================================
-- sp_CreateDeck
-- Cria um novo deck para um usuario existente.
-- Retorna o DeckID recem-criado.
-- ================================================

CREATE OR ALTER PROCEDURE sp_CreateDeck
    @UserID      INT,
    @Title       NVARCHAR(100),
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    -- Evita mensagem de "N rows affected" e deixa o retorno mais limpo.
    SET NOCOUNT ON;

    -- Valida se o usuario informado existe antes de inserir.
    IF NOT EXISTS (SELECT 1
    FROM Users
    WHERE UserID = @UserID)
    BEGIN
        -- Erro de negocio: nao permite criar deck sem usuario valido.
        RAISERROR('User not found.', 16, 1);
        RETURN;
    END

    -- Cria o deck com titulo obrigatorio e descricao opcional.
    INSERT INTO Decks
        (UserID, Title, Description)
    VALUES
        (@UserID, @Title, @Description);

    -- Retorna o ID gerado no mesmo escopo da insercao.
    SELECT SCOPE_IDENTITY() AS NewDeckID;
END
GO

-- ================================================
-- sp_AddCard
-- Adiciona um novo card em um deck existente.
-- Retorna o CardID recem-criado.
-- ================================================

CREATE OR ALTER PROCEDURE sp_AddCard
    @DeckID INT,
    @Front  NVARCHAR(MAX),
    @Back   NVARCHAR(MAX)
AS
BEGIN
    -- Evita mensagem de "N rows affected" e deixa o retorno mais limpo.
    SET NOCOUNT ON;

    -- Garante que o deck exista antes de inserir o card.
    IF NOT EXISTS (SELECT 1
    FROM Decks
    WHERE DeckID = @DeckID)
    BEGIN
        -- Erro de negocio: nao permite adicionar card em deck inexistente.
        RAISERROR('Deck not found.', 16, 1);
        RETURN;
    END

    -- Insere frente e verso do card associados ao deck.
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (@DeckID, @Front, @Back);

    -- Retorna o ID gerado no mesmo escopo da insercao.
    SELECT SCOPE_IDENTITY() AS NewCardID;
END
GO

-- ================================================
-- sp_UpdateCard
-- Atualiza o Front e/ou Back de um card existente.
-- Se um parametro vier NULL, mantem o valor atual da coluna.
-- ================================================

CREATE OR ALTER PROCEDURE sp_UpdateCard
    @CardID INT,
    @Front  NVARCHAR(MAX) = NULL,
    @Back   NVARCHAR(MAX) = NULL
AS
BEGIN
    -- Evita mensagem de "N rows affected" e deixa o retorno mais limpo.
    SET NOCOUNT ON;

    -- Garante que o card exista antes de atualizar.
    IF NOT EXISTS (SELECT 1
    FROM Cards
    WHERE CardID = @CardID)
    BEGIN
        -- Erro de negocio: nao permite atualizar card inexistente.
        RAISERROR('Card not found.', 16, 1);
        RETURN;
    END

    -- Atualiza apenas os campos informados e registra data/hora da alteracao.
    UPDATE Cards
    SET
        Front     = ISNULL(@Front, Front),
        Back      = ISNULL(@Back,  Back),
        UpdatedAt = GETDATE()
    WHERE CardID = @CardID;
END
GO

-- ================================================
-- sp_DeleteCard
-- Remove um card especifico pelo ID.
-- ================================================

CREATE OR ALTER PROCEDURE sp_DeleteCard
    @CardID INT
AS
BEGIN
    -- Evita mensagem de "N rows affected" e deixa o retorno mais limpo.
    SET NOCOUNT ON;

    -- Garante que o card exista antes de excluir.
    IF NOT EXISTS (SELECT 1
    FROM Cards
    WHERE CardID = @CardID)
    BEGIN
        -- Erro de negocio: nao permite excluir card inexistente.
        RAISERROR('Card not found.', 16, 1);
        RETURN;
    END

    -- Exclui o registro alvo da tabela Cards.
    DELETE FROM Cards WHERE CardID = @CardID;
END
GO

-- Create a new deck
EXEC sp_CreateDeck @UserID = 1, @Title = 'SQL Basics', @Description = 'Core SQL concepts';

-- Add a card to it (use the DeckID returned above)
EXEC sp_AddCard @DeckID = 4, @Front = 'What does SELECT do?', @Back = 'Retrieves rows from a table';

-- Update only the Back of a card (Front stays unchanged)
EXEC sp_UpdateCard @CardID = 1, @Back = 'Updated answer here';

-- Delete a card
EXEC sp_DeleteCard @CardID = 1;